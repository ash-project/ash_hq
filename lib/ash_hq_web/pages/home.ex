defmodule AshHqWeb.Pages.Home do
  @moduledoc "The home page"

  use Surface.LiveComponent

  alias AshHqWeb.Components.{CalloutText, CodeExample, SearchBar}
  alias Surface.Components.Form
  alias Surface.Components.Form.{Field, Submit, TextInput}
  import AshHqWeb.Components.CodeExample, only: [to_code: 1]

  data signed_up, :boolean, default: false
  data email_form, :any

  def render(%{__context__: %{platform: :ios}} = assigns) do
    ~F"""
    <vstack>
      <hstack>
        <text>Build</text> <CalloutText text="powerful" /><text>
          and
        </text>
        <CalloutText text="composable" /> <text>
          applications</text>
      </hstack>
      <hstack>
        <text>with a
        </text>
        <CalloutText text="flexible" /> <text>
          tool-chain.
        </text>
      </hstack>
      <hstack>
        <text font="callout">A declarative foundation for ambitious Elixir applications.</text>
      </hstack>
      <hstack>
        <text font="callout">Model your domain, derive the rest.</text>
      </hstack>
    </vstack>
    """
  end

  def render(assigns) do
    ~F"""
    <div class="antialiased">
      <div class="my-2 dark:bg-base-dark-900 flex flex-col items-center pt-4 md:pt-12">
        <div class="flex flex-col">
          <img class="h-64" src="/images/ash-logo-side.svg">
        </div>
        <div class="text-3xl md:text-5xl px-4 md:px-12 font-bold max-w-5xl mx-auto mt-8 md:text-center">
          Build <CalloutText text="powerful" /> and <CalloutText text="composable" /> applications with a <CalloutText text="flexible" /> tool-chain.
        </div>
        <div class="text-xl font-light text-base-dark-700 dark:text-base-light-100 max-w-4xl mx-auto px-4 md:px-0 mt-4 md:text-center">
          A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest.
        </div>
        <div class="flex flex-col space-y-4 md:space-x-4 md:space-y-0 md:flex-row items-center mt-8 md:mt-16 mb-6 md:mb-10">
          <div class="flex justify-center items-center w-full md:w-auto h-12 px-4 rounded-lg bg-primary-light-500 dark:bg-primary-dark-500 font-semibold dark:text-white dark:hover:bg-primary-dark-700 hover:bg-primary-light-700">
            <a href="/docs/guides/ash/latest/tutorials/get-started.md" target="_blank">Get Started</a>
          </div>
          <SearchBar class="w-80 md:w-96" />
        </div>

        <div class="flex flex-col">
          <div class="max-w-7xl px-4 sm:px-6 md:px-8 mb-8">
            <h2 class="mt-8 font-semibold text-primary-light-500 dark:text-primary-dark-400">
              Framework
            </h2>
            <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
              What is Ash?
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Ash Framework is a declarative, resource-oriented application
              development framework for Elixir. A resource can model anything,
              like a database table, an external API, or even custom code. Ash
              provides a rich, and extensive set of tools for interacting with
              and building on top of these resources. By modeling your
              application as a set of resources, other tools know exactly how to
              use them, allowing extensions like AshGraphql and AshJsonApi to
              provide top tier APIs with minimal configuration. With
              filtering/sorting/pagination/calculations/aggregations, pub/sub,
              policy authorization, rich introspection, and much more built-in,
              and a comprehensive suite of tools to allow you to build your own
              extensions, the possibilities are endless.
            </p>
          </div>
          <div class="max-w-7xl px-4 sm:px-6 md:px-8 mb-8">
            <h2 class="mt-8 font-semibold text-primary-light-500 dark:text-primary-dark-400">
              Write it once
            </h2>
            <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
              Why do developers keep reinventing the wheel?
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Every time you start a new app, are you rebuilding features that you've already built many times?
              Wouldn't it be great if you could just focus on the important parts of an app without reinventing ways to authenticate, add permissions, etc.
              Ash allows you to not only use patterns in existing extensions, it lets you extract your own patterns into custom extensions.
              So when you need to do it again in a new application, it's already done. Just wire it up!
            </p>
          </div>

          <div class="max-w-7xl px-4 sm:px-6 md:px-8 mb-8">
            <h2 class="mt-8 font-semibold text-primary-light-500 dark:text-primary-dark-400">
              Consistency
            </h2>
            <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
              A place for everything and everything in it's place
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Ash helps keep things neat and organized by providing good patterns for structuring your application.
              Over time and with larger teams of different experience levels,
              patterns change and drift away from each-other across our applications.
              With that said, nothing in Ash depends on what folders or files you put things in, so you are
              free to experiment or make the choices that make sense to you.
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Spaghetti belongs in the kitchen, not in your codebase.
              Ash provides the ability to keep all similar parts of your application consistent,
              making it easy to share an architectural vision while allowing escape hatches to do something different if needed.
            </p>
          </div>

          <div class="max-w-7xl px-4 sm:px-6 md:px-8 mb-8">
            <h2 class="mt-8 font-semibold text-primary-light-500 dark:text-primary-dark-400">
              Incredibly Powerful
            </h2>
            <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
              Ash is more than it appears
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Ash is more than just auto-generated API or an Admin UI.
              It’s a fully extensible DSL to model your domain, which creates a declarative,
              highly introspectable representation. This in turn can be used to derive anything you want.
            </p>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              Ash has built in extensions that allow you to generate Admin UIs or Phoenix LiveView Form helpers,
              saving a ton of boilerplate. Even going as far as fully swapping data layers, Ash lets you do
              something traditionally extremely difficult with ease.
            </p>
          </div>
        </div>

        <div class="flex flex-col w-full dark:bg-none dark:bg-opacity-0 py-6">
          <div class="flex flex-col w-full">
            <div class="flex flex-row text-center justify-center w-full text-2xl text-black dark:text-white">
              Brought to you by
            </div>
            <div class="flex flex-row mt-6 justify-center">
              <a href="https://alembic.com.au">
                <img class="h-16" src="/images/alembic.svg">
              </a>
            </div>
          </div>

          <div class="flex flex-row justify-center mt-12">
            <a href="https://coinbits.app/">
              <img class="h-6" src="/images/coinbits-logo.png">
            </a>
          </div>
        </div>

        <div
          id="testimonials"
          class="flex flex-col items-center content-center space-y-8 w-full lg:w-[28rem] max-w-7xl md:h-[74rem] lg:h-[86rem] mb-8 lg:mb-0 px-4 md:px-8 lg:px-0"
        >
          <div class="w-full md:w-[26rem] lg:min-w-fit lg:max-w-min bg-base-light-200 rounded-xl p-8 md:p-0 dark:bg-base-dark-700 drop-shadow-xl md:relative lg:top-16 md:-left-[8rem] lg:-left-[10rem]">
            <div class="pt-6 md:p-8 text-center md:text-left space-y-4">
              <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
                "Through its declarative extensibility, Ash delivers more than you'd expect: Powerful APIs with filtering/sorting/pagination/calculations/aggregations, pub/sub, authorization, rich introspection, GraphQL... It's what empowers this solo developer to build an ambitious ERP!"
              </p>

              <p>
                <div class="font-bold text-primary-light-500 dark:text-primary-dark-400">
                  Frank Dugan III
                </div>
                <div class="text-base-light-700 dark:text-base-dark-200">
                  System Specialist, SunnyCor Inc.
                </div>
              </p>
            </div>
          </div>

          <div class="w-full md:w-[26rem] lg:min-w-fit lg:max-w-min bg-base-light-100 rounded-xl p-8 md:p-0 dark:bg-base-dark-600 drop-shadow-xl md:relative md:-top-16 md:-right-[10rem]">
            <div class="pt-6 md:p-8 text-center md:text-left space-y-4">
              <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
                "What stood out to me was how incredibly easy Ash made it for me to go from a proof of concept, to a working prototype using ETS, to a live app using Postgres."
              </p>

              <p>
                <div class="font-bold text-primary-light-500 dark:text-primary-dark-400">
                  Brett Kolodny
                </div>
                <div class="text-base-light-700 dark:text-base-dark-200">
                  Full stack engineer, MEW
                </div>
              </p>
            </div>
          </div>

          <div class="w-full md:w-[26rem] lg:min-w-fit lg:max-w-min bg-base-light-200 rounded-xl p-8 md:p-0 dark:bg-base-dark-700 drop-shadow-xl md:relative md:-top-32 md:-left-[11rem]">
            <div class="pt-6 md:p-8 text-center md:text-left space-y-4">
              <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
                "Ash is an incredibly powerful idea that gives Alembic a massive competitive advantage. It empowers us to build wildly ambitious applications for our clients with tiny teams, while consistently delivering the high level of quality that our customers have come to expect."
              </p>

              <p>
                <div class="font-bold text-primary-light-500 dark:text-primary-dark-400">
                  Josh Price
                </div>
                <div class="text-base-light-700 dark:text-base-dark-100">
                  Technical Director, Alembic
                </div>
              </p>
            </div>
          </div>

          <div class="w-full md:w-[26rem] lg:min-w-fit lg:max-w-min bg-base-light-100 rounded-xl p-8 md:p-0 dark:bg-base-dark-600 drop-shadow-xl md:relative md:-top-[4rem] md:-top-64 md:-right-44">
            <div class="pt-6 md:p-8 text-center md:text-left space-y-4">
              <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
                "Ash Framework enabled us to build a robust platform for delivering financial services using bitcoin. Ash proved itself to our team by handling innovative use cases with ease and it continues to evolve ahead of our growing list of needs."
              </p>

              <p>
                <div class="font-bold text-primary-light-500 dark:text-primary-dark-400">
                  Yousef Janajri
                </div>
                <div class="text-base-light-700 dark:text-base-dark-100">
                  CTO & Co-Founder, Coinbits
                </div>
              </p>
            </div>
          </div>

          <div class="w-full md:w-[26rem] lg:min-w-fit lg:max-w-min bg-base-light-200 rounded-xl p-8 md:p-0 dark:bg-base-dark-700 drop-shadow-xl md:relative md:-top-[20rem] md:-left-[11rem]">
            <div class="pt-6 md:p-8 text-center md:text-left space-y-4">
              <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
                "The more I’ve used Ash, the more blown away I am by how much I get out of it – and how little boilerplate I have to write. I’m yet to encounter a situation where I would need to fight the “Ash way” of doing things, but the framework still allows me to choose how I build my software."
              </p>

              <p>
                <div class="font-bold text-primary-light-500 dark:text-primary-dark-400">
                  Juha Lehtonen
                </div>
                <div class="text-base-light-700 dark:text-base-dark-100">
                  Senior Software Developer
                </div>
              </p>
            </div>
          </div>
        </div>

        <div class="flex flex-col text-center items-center mt-24">
          <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50 mb-16">
            It wouldn't be possible without our amazing community!
          </p>

          <a href="https://github.com/ash-project/ash/graphs/contributors">
            <img src="https://contrib.rocks/image?repo=ash-project/ash">
          </a>

          <a
            href="docs/guides/ash/latest/how_to/contribute.md"
            class="flex justify-center items-center w-full md:w-auto h-10 px-4 rounded-lg bg-primary-light-500 dark:bg-primary-dark-500 font-semibold dark:text-white dark:hover:bg-primary-dark-700 hover:bg-primary-light-700 mt-6"
          >
            Become a contributor
          </a>
        </div>

        <div class="flex flex-col items-center my-10 space-y-4">
          {#if @signed_up}
            Thank you for joining our mailing list!
          {#else}
            <p class="text-2xl font-medium text-base-light-700 dark:text-base-light-50 max-w-4xl mx-auto text-center">Join our mailing list for (tastefully paced) updates!</p>
            <Form
              for={@email_form}
              change="validate_email_form"
              submit="submit_email_form"
              class="flex flex-col md:flex-row space-x-4 space-y-4 items-center"
            >
              <Field name={:email}>
                <TextInput
                  class="w-80 md:w-96 button border border-base-light-400 bg-base-light-200 dark:border-base-dark-700 rounded-lg dark:bg-base-dark-700 hover:bg-base-light-300 dark:hover:bg-base-dark-600"
                  opts={placeholder: "user@email.com"}
                />
              </Field>
              <Submit class="flex justify-center items-center w-full md:w-auto h-10 px-4 rounded-lg bg-primary-light-500 dark:bg-primary-dark-500 font-semibold dark:text-white dark:hover:bg-primary-dark-700 hover:bg-primary-light-700">Join</Submit>
            </Form>
          {/if}
        </div>

        <div class="block md:hidden my-8" />

        <div class="max-w-7xl px-4 sm:px-6 md:px-8 my-8 hidden sm:block">
          <h2 class="mt-8 font-semibold text-red-500 dark:text-red-400">
            Simple declarative DSL
          </h2>
          <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
            A taste of how to configure Ash
          </p>
          <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
            Below are some examples of the way you can model your resources with actions, attributes and relationships.
            You can easily swap data layers between Postgres or ETS for example, or add your own data layer extension.
            Once you've modelled your resources, you can derive GraphQL or JSON API external APIs from them.
          </p>
        </div>

        <div class="pt-6 pb-6 w-full max-w-6xl">
          <div class="flex flex-col lg:flex-row gap-10 mx-8 lg:mx-0">
            <CodeExample
              id="define-a-resource"
              class="grow w-full lg:w-min max-w-[1000px]"
              code={post_example()}
              title="Define a resource"
            />
            <div class="flex flex-col gap-10 w-full">
              <div class="flex flex-col space-y-8">
                <CodeExample
                  class="w-full"
                  collapsible
                  id="use-it-programmatically"
                  code={changeset_example()}
                  title="Use it programmatically"
                />
                <CodeExample
                  class="w-auto"
                  collapsible
                  id="graphql-interface"
                  code={graphql_example()}
                  title="Add a GraphQL interface"
                />
                <CodeExample
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="authorization-policies"
                  code={policies_example()}
                  title="Add authorization policies"
                />
                <CodeExample
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="aggregates"
                  code={aggregate_example()}
                  title="Define aggregates and calculations"
                />
                <CodeExample
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="pubsub"
                  code={notifier_example()}
                  title="Broadcast changes over Phoenix PubSub"
                />
                <CodeExample
                  class="w-atuo"
                  collapsible
                  start_collapsed
                  id="live-view"
                  code={live_view_example()}
                  title="Use it with Phoenix LiveView"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def mount(socket) do
    {:ok,
     assign(
       socket,
       signed_up: false,
       email_form:
         AshPhoenix.Form.for_create(AshHq.MailingList.Email, :create,
           api: AshHq.MailingList,
           upsert?: true,
           upsert_identity: :unique_email
         )
     )}
  end

  def handle_event("validate_email_form", %{"form" => form}, socket) do
    {:noreply,
     assign(socket, email_form: AshPhoenix.Form.validate(socket.assigns.email_form, form))}
  end

  def handle_event("submit_email_form", _, socket) do
    case AshPhoenix.Form.submit(socket.assigns.email_form) do
      {:ok, _} ->
        {:noreply, assign(socket, :signed_up, true)}

      {:error, form} ->
        {:noreply, assign(socket, email_form: form)}
    end
  end

  @changeset_example """
                     post = Example.Post.create!(%{
                       text: "Declarative programming is fun!"
                     })

                     Example.Post.react!(post, %{type: :like})

                     Example.Post
                     |> Ash.Query.filter(likes > 10)
                     |> Ash.Query.sort(likes: :desc)
                     |> Example.read!()
                     """
                     |> to_code()

  defp changeset_example do
    @changeset_example
  end

  @live_view_example """
                     def mount(_params, _session, socket) do
                       form = AshPhoenix.Form.for_create(Example.Post, :create)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("validate", %{"form" => input}, socket) do
                       form = AshPhoenix.Form.validate(socket.assigns.form, input)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("submit", _, socket) do
                       case AshPhoenix.Form.submit(socket.assigns.form) do
                         {:ok, post} ->
                           {:ok, redirect_to_post(socket, post)}

                         {:error, form_with_errors} ->
                           {:noreply, assign(socket, :form, form_with_errors)}
                       end
                     end
                     """
                     |> to_code()
  defp live_view_example do
    @live_view_example
  end

  @graphql_example """
                   graphql do
                     type :post

                     queries do
                       get :get_post, :read
                       list :feed, :read
                     end

                     mutations do
                       create :create_post, :create
                       update :react_to_post, :react
                     end
                   end
                   """
                   |> to_code()
  defp graphql_example do
    @graphql_example
  end

  @policies_example """
                    policies do
                      policy action_type(:read) do
                        authorize_if expr(visibility == :everyone)
                        authorize_if relates_to_actor_via([:author, :friends])
                      end
                    end
                    """
                    |> to_code()
  defp policies_example do
    @policies_example
  end

  @notifier_example """
                    pub_sub do
                      module ExampleEndpoint
                      prefix "post"

                      publish_all :create, ["created"]
                      publish :react, ["reaction", :id] event: "reaction"
                    end
                    """
                    |> to_code()
  defp notifier_example do
    @notifier_example
  end

  @aggregate_example """
                     aggregates do
                       count :likes, :reactions do
                         filter expr(type == :like)
                       end

                       count :dislikes, :reactions do
                         filter expr(type == :dislike)
                       end
                     end

                     calculations do
                       calculate :like_ratio, :float do
                         expr(likes / (likes + dislikes))
                       end
                     end
                     """
                     |> to_code()

  defp aggregate_example do
    @aggregate_example
  end

  @post_example """
                defmodule Example.Post do
                  use AshHq.Resource,
                    data_layer: AshPostgres.DataLayer

                  resource do
                    description "A post is the primary sharable entity in our system"
                  end

                  postgres do
                    table "posts"
                    repo Example.Repo
                  end

                  attributes do
                    attribute :text, :string do
                      allow_nil? false
                      description "The body of the text"
                    end

                    attribute :visibility, :atom do
                      constraints [
                        one_of: [:friends, :everyone]
                      ]
                      description "Which set of users this post should be visible to"
                    end
                  end

                  actions do
                    update :react do
                      argument :type, Example.Types.ReactionType do
                        allow_nil? false
                      end

                      change manage_relationship(
                        :type,
                        :reactions,
                        type: :append
                      )
                    end
                  end

                  relationships do
                    belongs_to :author, Example.User do
                      allow_nil? true
                    end

                    has_many :reactions, Example.Reaction
                  end
                end
                """
                |> to_code()

  defp post_example do
    @post_example
  end
end
