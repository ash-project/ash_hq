defmodule AshHqWeb.Routes do
  def library_link(library, name) do
    "/docs/dsl/#{sanitize_name(library.name)}/#{sanitize_name(name)}"
  end

  def doc_link(entity, selected_versions \\ %{})

  def doc_link(%AshHq.Docs.Library{name: name}, _selected_version) do
    "/docs/dsl/#{sanitize_name(name)}"
  end

  def doc_link(
        %AshHq.Docs.Module{
          name: name,
          library_name: library_name,
          version_name: version_name,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/module/#{sanitize_name(library_name)}/#{version(version_name, library_id, selected_versions)}/#{sanitize_name(name)}"
  end

  def doc_link(
        %AshHq.Docs.Function{
          name: name,
          arity: arity,
          type: type,
          module_name: module_name,
          library_name: library_name,
          version_name: version_name,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/module/#{sanitize_name(library_name)}/#{version(version_name, library_id, selected_versions)}/#{sanitize_name(module_name)}/##{type}-#{sanitize_name(name)}-#{arity}"
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
    "/docs/guides/#{sanitize_name(library_name)}/#{version(version, library_id, selected_versions)}/#{route}"
  end

  def doc_link(
        %AshHq.Docs.LibraryVersion{
          library_name: library_name,
          version: version,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/dsl/#{sanitize_name(library_name)}/#{version(version, library_id, selected_versions)}"
  end

  def doc_link(
        %AshHq.Docs.Extension{
          library_version: %{
            library_name: library_name,
            version: version,
            library_id: library_id
          },
          name: name
        },
        selected_versions
      ) do
    "/docs/dsl/#{sanitize_name(library_name)}/#{version(version, library_id, selected_versions)}/#{sanitize_name(name)}"
  end

  def doc_link(item, selected_versions) do
    case item do
      %AshHq.Docs.Dsl{} = item ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{version(item.version_name, item.library_id, selected_versions)}/#{sanitize_name(item.extension_name)}/#{Enum.map_join(item.path ++ [item.name], "/", &sanitize_name/1)}"

      %AshHq.Docs.Option{} = item ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{version(item.version_name, item.library_id, selected_versions)}/#{sanitize_name(item.extension_name)}/#{Enum.map_join(item.path, "/", &sanitize_name/1)}##{item.name}"
    end
  end

  defp version(version_name, library_id, selected_versions) do
    if selected_versions[library_id] == "latest" do
      "latest"
    else
      version_name
    end
  end

  def sanitize_name(name) do
    String.downcase(String.replace(name, ~r/[^A-Za-z0-9_]/, "-"))
  end
end
