+++
title = "There are macros and there are *macros*"
description = "Not all macros are built the same."
date = 2023-05-11T20:00:29Z
authors = ["Zach Daniel"]

[taxonomies]
tags = ["elixir", "ash", "macros"]
+++

A common criticism of Ash is that it has too many macros. This is an understandable position to take, but I think its important to distinguish between two main kinds of macros. One of them should be used extremely sparingly, and the other I think its okay to use a bit more liberally. We'll call them "configuration macros" and "metaprogramming macros". Keep in mind these names are a bit made up and the boundary between the two is not always cut and dry. When people talk about "magic" in the context of macros, they are mostly talking about "metaprogramming macros". Lets take a look at some examples.

## Metaprogramming Macros

This snippet is from [NX](https://github.com/elixir-nx/nx/tree/main/nx#readme). This function can run as regular elixir code, or it can be compiled to run using multiple backends meant for numerical processing, including running on the GPU. The code that is actually compiled under the hood looks _dramatically_ different from what you see in front of you. This is not a bad thing! If you had to use or write the actual underlying code, you'd get nothing done. Check out Nx's documentation for more.

```elixir
defn softmax(t) do
  Nx.exp(t) / Nx.sum(Nx.exp(t))
end
```

Here is an example from `Nebulex`, an ETS based caching library. In this example, the metaprogramming is quite hidden from you. The actual logic happens in a [_compiler callback_](https://hexdocs.pm/elixir/1.12/Module.html#module-compile-callbacks). It involves rewriting the functions to intercept calls and decide if the cached version should be used, or if the value should be computed and cached. This kind of macro is quite magical given how indirect it is, but at the same time in applications where cached functions are common, it stops feeling like magic and starts feeling like a language feature. If I was looking at a large code-base that used this once, I'd likely be concerned. The mental overhead of understanding it for one single case likely isn't worth it.

```elixir
defmodule MyApp.Example do
  use Nebulex.Caching

  @decorate cacheable(cache: MyApp.Cache, key: :cache_key)
  def get_by_name(name, age) do
    ...
  end
end
```

This one is from `Ash`. We do similar magic to the `Nx` example from above for this. Specifically, we have an expression that can be run natively to a data layer (i.e `SQL`) or in elixir. And Ash reserves the right to decide where it gets run, depending on the context and requirements.

```elixir
calculate :full_name, :string, expr(first_name <> " " <> last_name)
```

As you can see, all of these examples represent a significant amount of complexity boiled down to very simple macros. This will also be true of the upcoming examples of "configuration macros", but the big difference here is that each macro call represents very complex code being executed on your behalf.

## Configuration Macros

Lets take a look at some examples of macros that I would consider _less_ magical.

This one is likely familiar to most people who have worked with Elixir professionally. Here we have an Ecto.Schema. In this example we actually have three separate macros. The `schema/2` macro sets up some module attributes, and `field/2` adds to those module attributes. `timestamps/0` sets up the schema to track `inserted_at` and `updated_at` timestamps. On its own, however, an `Ecto.Schema` doesn't really _do_ anything. There also isn't a bunch of code hidden behind the scenes that you need to be aware of being executed. This sets up some information on the module that can be read back later. For example: `MyApp.MySchema.__schema__(:fields)` would return `[:field_name, :inserted_at, :updated_at]` in this case. This is a classic example of what I'd call a "configuration macro".

```elixir
defmodule MyApp.MySchema do
  schema "table" do
    field :field_name, :type

    timestamps()
  end
end
```

Here we can see an example from `Absinthe`'s documentation. Absinthe is a tool for building GraphQL apis with Elixir. This one slightly straddles the line between "configuration macros" and "metaprogramming macros", but I think still lands on the side of a "configuration macro". We configure a field in our GraphQL API, and how to resolve it. There are quite a few macros involved in building an API with `Absinthe`. Here we configure what code gets run to resolve a given field, but ultimately the responsibility for what code runs is our own.

```elixir
defmodule BlogWeb.Schema do
  use Absinthe.Schema
  ...

  query do
    @desc "Get all posts"
    field :posts, list_of(:post) do
      resolve &Resolvers.Content.list_posts/3
    end
  end
end
```

Finally, lets take a look at some code from an `Ash.Resource`. I'll choose a relatively complex example, specifically the defining of an "action".

```elixir
create :create do
  primary? true

  accept [:text]

  argument :public, :boolean do
    allow_nil? false
    default true
  end

  change fn changeset, _ ->
    if Ash.Changeset.get_argument(changeset, :public) do
      Ash.Changeset.force_change_attribute(changeset, :visibility, :public)
    else
      changeset
    end
  end

  change relate_actor(:author)
end
```

For those not familiar with Ash, lets break it down.

- `primary? true` means that if something wants to create one of these, this is the action it should call by default. This is used by certain internal actions and can be used by you or other extensions to determine which action to call in lieu of an explicitly configured action.

- `accept [:text]` means that you can set the `text` attribute when calling this action.

- `argument :public, :boolean, …` adds an additional input to the action that doesn’t map to an attribute, called `:public` that must have a value, but defaults to `true`.

- The anonymous function you see with `change fn changeset, _ ->` is what we call an "inline change". A `change` is a function that takes a changes and returns a changeset. If you’ve worked with Phoenix or with Plug, you’ll recognize this pattern, it works effectively the same as `Plug`, working on a `Conn`. Except in this case, its a `change` working on an `Ash.Changeset`. We use this argument to map a boolean toggle input to an enumerated attribute.
  `change relate_actor(:author)` refers to a "built in change". This change is provided by Ash out of the box, and this relates the actor (A.K.A current user) to the thing that was just created as the `:author`.

These are all macros! However, they again map to an introspectable structure, acting more as configuration than as a traditional macro.

```elixir
iex(1)> Ash.Resource.Info.action(Twitter.Tweets.Tweet, :create)
%Ash.Resource.Actions.Create{
  name: :create,
  primary?: true,
  type: :create,
  …
  arguments: [
    %Ash.Resource.Actions.Argument{
      name: :public,
      …
    }
  ],
  changes: [
    %Ash.Resource.Change{...},
    %Ash.Resource.Change{
      change: {Ash.Resource.Change.RelateActor,
       [allow_nil?: false, relationship: :author]},
      …
    }
  ],
  …
}
```

This inversion of control is something we're familiar with in other tools like `Plug` or `Phoenix.Endpoint/Router`. They are great examples of how this pattern can allow for code reuse, and make complex chains of behavior easier to reason about.

## Its not necessarily about macros

Above I've made a case for macros not necessarily being what gives Ash its relatively steep learning curve. We've also create a large suite of tools to mitigate the difficulties that these configuration macros can have. Take a look at [spark](https://hex.pm/packages/spark) for more information on those tools.

With that said, in that one example above, we had to add five new words to our vocabulary. This is what can make Ash difficult. When you set out to write your own application patterns, you can let your own vocabulary evolve. This provides a natural learning curve. I'd also argue that it gives you tons of opportunities to repeat the mistakes of every developer who went through that same process.

## Therein lies the rub

Ash presents a huge suite of integrated tools, a suite that gets bigger and bigger every day and, in order to leverage it, you need to learn a whole new way of doing things. This is a very valid reason not to use Ash. Our biggest proponents will tell you that it’s worth it to put in the effort to learn these tools. As would I. And I don’t mean for the idea of what the framework may become, but for the benefits you can get right now.

With that said, I think a diversity of mindsets is the most important thing that we can foster as a community, and there is a fine line between telling people "Hey, I think we’ve got some good ideas over here, I think you should check them out", and saying "Hey, this is the right way to do things, stop doing things your way and do them our way". So while I’m of course a proponent of Ash, my plan is not to _talk anyone into using it_. I have one simple goal, which is to continue to expand this integrated suite of tools, adding new capabilities that are only possible for things built in this way. Ash is a snowball, rolling down a hill, and it has barely even begun to gather snow. By doing this, we move the threshold by which cost of learning the "Ash way" is offset by the benefits. For many users (more every day) that threshold has already been crossed. For others, it may never be crossed, and thats okay 😊. If the tools we build can help even one person find success on their Elixir journey, then I’m a happy camper.

## Parting Words

The cost of learning something like Ash is not trivial. It depends on you, your problem space, your experience level, and many other factors as to whether or not that juice is worth the squeeze. My goal, and the core team's goal, is to continue to provide leverage for those already using Ash. To take the patterns we've set down and take them even further, increasing the value of our existing users' investments. Partially because we count among those users, but also because we believe in what we're building and its ability to help us and others build bigger and better software.
