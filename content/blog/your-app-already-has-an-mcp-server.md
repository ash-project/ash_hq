+++
title = "Use Ash and get an MCP for free"
description = "How to turn an existing Ash application into an MCP server with Ash AI. Bonus: integrating with PostHog's MCP Analytics."
date = 2026-11-09T12:00:00Z
authors = ["Zach Daniel"]

[taxonomies]
tags = ["ash", "ai", "mcp"]

[extra]
og_image = "images/blog/your-app-already-has-an-mcp-server/og.png"
scripts = ["js/tool-derivation.js", "js/tool-listing.js"]
+++

Everybody wants an MCP server right now. Your customers want to point Claude or Cursor or ChatGPT at your product and have it _do things_. And for most teams, "add an MCP server" is its own multi-week (minimum) initiative. A new set of endpoints, a new auth story, a pile of JSON schemas to write and keep in sync, and a whole new surface area to secure.

If you're building with Ash, you already did almost all of that work. You just didn't know it yet.

I recently built [Moatless](https://moatless.store), a marketplace for codebases, where a big part of the pitch is that your agent can search for, buy, and sell codebases on your behalf. Its MCP server has around 40 tools. The MCP server itself is one `forward` in the router. The tools are one line each. Everything else (the inputs, the validation, the authorization, the errors) I get for free with Ash AI. Model your domain, derive the rest.

Lets see what it looks like:

## Install AshAi

```sh
mix igniter.install ash_ai --no-req-llm
```

AshAi does a lot of LLM-related things (prompt-backed actions, vectorization, tool loops), and the installer adds `req_llm` for those. If all you want is the MCP server, use `--no-req-llm` to skip that.

## Pick your tools

A tool is just an action you've decided to expose, with a name.

```elixir
defmodule MyApp.Blog do
  use Ash.Domain, extensions: [AshAi]

  tools do
    tool :list_posts, MyApp.Blog.Post, :read,
      title: "List posts",
      annotations: [read_only_hint: true]

    tool :get_post, MyApp.Blog.Post, :read,
      get_by: :id,
      title: "Get a post",
      annotations: [read_only_hint: true]

    tool :publish_post, MyApp.Blog.Post, :publish,
      title: "Publish a post",
      annotations: [destructive_hint: false]
  end
end
```

That's it. The tool's input schema comes from the action: its public arguments and accepted attributes, their types, their constraints, their descriptions. Read actions get filtering, sorting and pagination for free, limited to public fields. The `title` and annotations are what MCP clients use to decide how to present a tool and whether to ask the person before calling it (and some directories, like Claude's, flag tools that don't have them).

{{ <ui.tool_derivation /> }}

My advice: don't expose everything. Expose the actions you'd put in front of a user, with names and descriptions written for an agent. The descriptions on your actions and arguments _are_ the documentation the model reads, so this is a great excuse to go write good ones.

## Authenticate it

Your MCP server needs to know who's calling. For remote clients (Claude.ai connectors, ChatGPT, IDEs with OAuth support), that means OAuth 2.1 with dynamic client registration, which sounds like a nightmare to build, and it is. So don't build it:

```sh
mix igniter.install ash_authentication_oauth2_server
```

That scaffolds a full OAuth 2.1 authorization server on top of your existing AshAuthentication setup: PKCE, dynamic client registration, discovery metadata, a consent page, the works. Follow the notice at the end to mount its routes, then add a pipeline for the MCP server:

```elixir
pipeline :mcp do
  plug AshAuthentication.Phoenix.Oauth2Server.BearerPlug,
    oauth2_server: MyApp.Oauth2Server,
    required?: true
end
```

If your clients are configured by hand (a local IDE, a script, an internal tool), API keys are the quicker route. The [AshAi README](https://hexdocs.pm/ash_ai/readme.html) covers both.

## Mount it

```elixir
scope "/mcp" do
  pipe_through :mcp

  forward "/", AshAi.Mcp.Router,
    otp_app: :my_app,
    tools: [:list_posts, :get_post, :publish_post]
end
```

And you have an MCP server. Point Claude Code at it (`claude mcp add --transport http my-app https://my-app.com/mcp`), sign in when it asks, and start talking to your app.

## Security built in

The bearer plug sets the signed-in user as the actor, and every tool call is just an Ash action run with that actor. Which means every policy you've already written applies. Every validation, every change, every multitenancy rule, every field policy. There is no separate "MCP permissions" layer for you to forget to update when you add a new rule next month.

AshAi goes a step further and only _lists_ the tools the actor is allowed to use, by checking each action up front. An agent signed in as someone who can't publish posts never sees `publish_post` in the first place.

{{ <ui.tool_listing /> }}

If you've read my post on [concentrated liability](/blog/concentrated-liability/), this is the good side of that coin. The same declarative rules that power your web app, your JSON:API, your GraphQL API and your background jobs power your MCP server too. Write it once.

## Bonus: why are agents calling my tools?

Once agents are using your MCP server, you're going to want to know what they're doing with it. And the question that's surprisingly hard to answer: _why_? What was the person trying to get done?

PostHog has a really clever answer to that in their [MCP Analytics](https://posthog.com/docs/mcp-analytics) product. Their SDKs add a `context` argument to every tool, asking the agent to explain why it's calling it. The SDK strips the argument back out before your handler ever sees it, and records it on the event as `$mcp_intent`. Agents are happy to fill it in, and you end up with a running log of what people are actually trying to do with your product. They wrote up some fun findings from doing this across 63 million tool calls [here](https://posthog.com/blog/how-ai-agents-behave).

There's no Elixir SDK for it, but you don't need one. As of AshAi 1.5.2 the MCP router has the two hooks it takes:

- `tool_definition_transformer`, which lets you change each tool's definition before it's listed, and
- `tool_argument_transformer`, which lets you change a call's arguments before the action runs.

And every tool call now runs in a `[:ash_ai, :mcp, :tool_call]` telemetry span, with the arguments as the agent sent them, the actor, the result and the duration. So here's the whole integration, using the [PostHog Elixir library](https://hexdocs.pm/posthog):

```elixir
defmodule MyAppWeb.McpAnalytics do
  @description """
  Explain in 15-25 words, in third person, why this tool is called and how it supports \
  the user's goal. For analytics only. Never include personal data; refer to people by \
  role, such as "the user".\
  """

  def attach do
    :telemetry.attach(
      __MODULE__,
      [:ash_ai, :mcp, :tool_call, :stop],
      &__MODULE__.handle_event/4,
      nil
    )
  end

  # Every tool asks why it's being called
  def add_context(_tool, definition, _context) do
    update_in(definition, ["inputSchema"], fn schema ->
      schema
      |> Map.update("properties", %{"context" => property()}, &Map.put(&1, "context", property()))
      |> Map.update("required", ["context"], &["context" | &1])
    end)
  end

  defp property, do: %{"type" => "string", "description" => @description}

  # and the context is stripped before calling the action
  def take_context(_tool, arguments, _context) do
    {:ok, Map.delete(arguments, "context")}
  end

  def handle_event(_event, %{duration: duration}, %{actor: %{id: user_id}} = metadata, _config) do
    intent = metadata.arguments["context"]

    PostHog.bare_capture("$mcp_tool_call", user_id, %{
      "$mcp_source" => "posthog_mcp_analytics",
      "$mcp_server_name" => "MyApp",
      "$mcp_tool_name" => metadata.tool_name,
      "$mcp_intent" => intent,
      "$mcp_intent_source" => if(intent, do: "context_parameter"),
      "$mcp_is_error" => metadata.is_error,
      "$mcp_duration_ms" => System.convert_time_unit(duration, :native, :millisecond),
      "$session_id" => metadata.session_id
    })
  end

  def handle_event(_event, _measurements, _metadata, _config), do: :ok
end
```

Attach the handler when your application starts:

```elixir
def start(_type, _args) do
  MyAppWeb.McpAnalytics.attach()
  ...
end
```

And hand the router the two transformers:

```elixir
forward "/", AshAi.Mcp.Router,
  otp_app: :my_app,
  tools: [...],
  tool_definition_transformer: &MyAppWeb.McpAnalytics.add_context/3,
  tool_argument_transformer: &MyAppWeb.McpAnalytics.take_context/3
```

Because the events use PostHog's own names (`$mcp_tool_call`, `$mcp_intent` and friends), their MCP Analytics views just work. The [event reference](https://posthog.com/docs/mcp-analytics/events) lists everything else you can send: client names and versions, error types and messages, the model, and so on.

## Caution: Be careful with what you record 

The intent is free text written by a model, and the model will occasionally helpfully include someone's email address in it. I scrub emails and long numbers out before sending, and cap the length.  I also only record arguments for searching and reading listings, never for things that could include personal information like message sending. Consider how sensitive your domain is before using this pattern.

## Go build one

If you have an Ash app, you're a `mix igniter.install` and a `tools` block away from an MCP server that is exactly as secure as the rest of your application. Pick a handful of actions your users would want an agent to do for them, write good descriptions for them, and ship it. Then watch what people actually try to do with it, and let that tell you what to build next.
