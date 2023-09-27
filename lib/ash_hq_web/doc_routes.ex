defmodule AshHqWeb.DocRoutes do
  @moduledoc "Helpers for routing to results of searches"

  def doc_link(%AshHq.Docs.Library{name: name}) do
    "https://hexdocs.pm/#{name}"
  end

  def doc_link(%AshHq.Docs.MixTask{
        library_name: library_name,
        module_name: module_name
      }) do
    "https://hexdocs.pm/#{library_name}/#{module_name}.html"
  end

  def doc_link(%AshHq.Docs.Module{
        library_name: library_name,
        name: name
      }) do
    "https://hexdocs.pm/#{library_name}/#{name}.html"
  end

  def doc_link(%AshHq.Docs.Function{
        name: name,
        arity: arity,
        module_name: module_name,
        library_name: library_name
      }) do
    "https://hexdocs.pm/#{library_name}/#{module_name}.html##{name}/#{arity}"
  end

  def doc_link(%AshHq.Docs.Guide{
        route: route,
        library_version: %{
          library_name: library_name,
          version: version,
          library_id: library_id
        }
      }) do
    "/docs/guides/#{library_name}/latest/#{route}"
  end

  def doc_link(%AshHq.Docs.LibraryVersion{}) do
    raise "Shouldn't be called anymore"
  end

  def doc_link(%AshHq.Docs.Extension{
        library_version: %{
          library_name: library_name
        },
        module: module
      }) do
    "https://hexdocs.pm/#{library_name}/#{module}.html"
  end

  def doc_link(item) do
    "https://hexdocs.pm/#{item.library_name}/dsl-#{sanitize_name(String.trim_trailing(item.extension_module, ".Dsl"))}.html##{String.replace(item.sanitized_path, "/", "-")}"
  end

  def sanitize_name(name, allow_forward_slash? \\ false) do
    if allow_forward_slash? do
      String.downcase(String.replace(to_string(name), ~r/[^A-Za-z0-9\/_]/, "-"))
    else
      String.downcase(String.replace(to_string(name), ~r/[^A-Za-z0-9_]/, "-"))
    end
  end
end
