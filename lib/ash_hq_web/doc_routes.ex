defmodule AshHqWeb.DocRoutes do
  @moduledoc "Helpers for routing to results of searches"
  def library_link(library, name) do
    "/docs/dsl/#{library.name}/#{name}"
  end

  def doc_link(entity, selected_versions \\ %{})

  def doc_link(%AshHq.Docs.Library{name: name}, _selected_version) do
    "/docs/dsl/#{name}"
  end

  def doc_link(
        %AshHq.Docs.MixTask{
          sanitized_name: sanitized_name,
          library_name: library_name,
          version_name: version_name,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/mix_task/#{library_name}/#{version(version_name, library_id, selected_versions)}/#{sanitized_name}"
  end

  def doc_link(
        %AshHq.Docs.Module{
          sanitized_name: sanitized_name,
          library_name: library_name,
          version_name: version_name,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/module/#{library_name}/#{version(version_name, library_id, selected_versions)}/#{sanitized_name}"
  end

  def doc_link(
        %AshHq.Docs.Function{
          sanitized_name: sanitized_name,
          arity: arity,
          type: type,
          module_name: module_name,
          library_name: library_name,
          version_name: version_name,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/module/#{sanitize_name(library_name)}/#{version(version_name, library_id, selected_versions)}/#{sanitize_name(module_name)}##{type}-#{sanitized_name}-#{arity}"
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

  def doc_link(
        %AshHq.Docs.LibraryVersion{
          library_name: library_name,
          version: version,
          library_id: library_id
        },
        selected_versions
      ) do
    "/docs/dsl/#{library_name}/#{version(version, library_id, selected_versions)}"
  end

  def doc_link(
        %AshHq.Docs.Extension{
          library_version: %{
            library_name: library_name,
            version: version,
            library_id: library_id
          },
          sanitized_name: sanitized_name
        },
        selected_versions
      ) do
    "/docs/dsl/#{library_name}/#{version(version, library_id, selected_versions)}/#{sanitized_name}"
  end

  def doc_link(item, selected_versions) do
    case item do
      %AshHq.Docs.Dsl{} = item ->
        "/docs/dsl/#{item.library_name}/#{version(item.version_name, item.library_id, selected_versions)}/#{sanitize_name(item.extension_name)}/#{item.sanitized_path}"

      %AshHq.Docs.Option{} = item ->
        "/docs/dsl/#{item.library_name}/#{version(item.version_name, item.library_id, selected_versions)}/#{sanitize_name(item.extension_name)}/#{item.sanitized_path}##{item.name}"
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
