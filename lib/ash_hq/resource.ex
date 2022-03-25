defmodule AshHq.Resource do
  defmacro __using__(opts) do
    opts =
      if opts[:notifiers] && Ash.Notifier.PubSub in opts[:notifiers] do
        opts
      else
        opts
        |> Keyword.put_new(:notifiers, [])
        |> Keyword.update!(:notifiers, &[Ash.Notifier.PubSub | &1])
      end

    quote do
      use Ash.Resource, unquote(opts)

      pub_sub do
        module AshHqWeb.Endpoint

        prefix Module.split(__MODULE__)
               |> Enum.reverse()
               |> Enum.take(2)
               |> Enum.reverse()
               |> Enum.map(&Macro.underscore/1)
               |> Enum.join(".")

        publish_all :create, ["created"]
        publish_all :update, ["updated"]
        publish_all :destroy, ["destroyed"]
      end
    end
  end
end
