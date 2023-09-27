defmodule AshHqWeb.DocRoutes do
  @moduledoc "Helpers for routing to results of searches"

  def doc_link(entity, selected_versions \\ %{})

  def doc_link(%AshHq.Docs.Library{name: name}, _selected_version) do
    "https://hexdocs.pm/#{name}"
  end

  def doc_link(
        %AshHq.Docs.MixTask{
          library_name: library_name,
          module_name: module_name
        },
        _selected_versions
      ) do
    "https://hexdocs.pm/#{library_name}/#{module_name}.html"
  end

  def doc_link(
        %AshHq.Docs.Module{
          library_name: library_name,
          name: name
        },
        _selected_versions
      ) do
    "https://hexdocs.pm/#{library_name}/#{name}.html"
  end

  def doc_link(
        %AshHq.Docs.Function{
          name: name,
          arity: arity,
          module_name: module_name,
          library_name: library_name
        },
        _selected_versions
      ) do
    "https://hexdocs.pm/#{library_name}/#{module_name}.html##{name}/#{arity}"
  end

  def doc_link(
        %AshHq.Docs.Guide{
          route: route,
          library_version: %{
            library_name: library_name,
            version: version,
            library_id: library_id
          }
        },
        selected_versions
      ) do
    "/docs/guides/#{library_name}/#{version(version, library_id, selected_versions)}/#{route}"
  end

  def doc_link(%AshHq.Docs.LibraryVersion{}, _selected_versions) do
    raise "Shouldn't be called anymore"
  end

  def doc_link(
        %AshHq.Docs.Extension{
          library_version: %{
            library_name: library_name
          },
          module: module
        },
        _selected_versions
      ) do
    "https://hexdocs.pm/#{library_name}/#{module}.html"
  end

  def doc_link(item, _selected_versions) do
    "https://hexdocs.pm/#{item.library_name}/dsl-#{sanitize_name(String.trim_trailing(item.extension_module, ".Dsl"))}.html##{String.replace(item.sanitized_path, "/", "-")}"
  end

  defp version(version_name, library_id, selected_versions) do
    if selected_versions[library_id] == "latest" do
      "latest"
    else
      version_name
    end
  end

  def sanitize_name(name, allow_forward_slash? \\ false) do
    if allow_forward_slash? do
      String.downcase(String.replace(to_string(name), ~r/[^A-Za-z0-9\/_]/, "-"))
    else
      String.downcase(String.replace(to_string(name), ~r/[^A-Za-z0-9_]/, "-"))
    end
  end
end
