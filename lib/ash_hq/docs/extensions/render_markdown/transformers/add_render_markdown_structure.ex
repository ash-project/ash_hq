defmodule AshHq.Docs.Extensions.RenderMarkdown.Transformers.AddRenderMarkdownStructure do
  @moduledoc """
  Adds the resource structure required for the render markdown extension

  Currently, this simply adds the relevant change and adds the destination
  attributes to the `allow_nil_input` of each action, since it will be adding them automatically.
  """

  use Ash.Dsl.Transformer
  alias Ash.Dsl.Transformer

  def transform(resource, dsl) do
    resource
    |> AshHq.Docs.Extensions.RenderMarkdown.render_attributes()
    |> Enum.reduce({:ok, dsl}, fn {source, destination}, {:ok, dsl} ->
      {:ok,
       dsl
       |> allow_nil_input(resource, destination)
       |> Transformer.add_entity(
         [:changes],
         Transformer.build_entity!(Ash.Resource.Dsl, [:changes], :change,
           change:
             {AshHq.Docs.Extensions.RenderMarkdown.Changes.RenderMarkdown,
              source: source, destination: destination}
         )
       )}
    end)
  end

  defp allow_nil_input(dsl, resource, destination) do
    resource
    |> Ash.Resource.Info.actions()
    |> Enum.filter(&(&1.type == :create))
    |> Enum.reduce(dsl, fn action, dsl ->
      Transformer.replace_entity(
        dsl,
        [:actions],
        %{action | allow_nil_input: (action.allow_nil_input || []) ++ [destination]},
        &(&1.name == action.name)
      )
    end)
  end

  def after?(_), do: true
end
