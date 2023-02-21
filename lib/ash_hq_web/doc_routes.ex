defmodule AshHqWeb.DocRoutes do
  @moduledoc "Helpers for routing to results of searches"
  def library_link(library, name) do
    "/docs/dsl/#{library.name}/#{name}"
  end

  def dsl_link(target) do
    "/docs/dsl/#{sanitize_name(target)}"
  end

  def doc_link(entity, selected_versions \\ %{})

  def doc_link(
        %AshHq.Discord.Message{thread_id: thread_id, channel_name: channel_name},
        _selected_version
      ) do
    "/forum/#{channel_name}/#{thread_id}"
  end

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

  def doc_link(item, _selected_versions) do
    case item do
      %AshHq.Docs.Dsl{} = item ->
        "/docs/dsl/#{sanitize_name(item.extension_target)}##{String.replace(item.sanitized_path, "/", "-")}"

      %AshHq.Docs.Option{} = item ->
        "/docs/dsl/#{sanitize_name(item.extension_target)}##{String.replace(item.sanitized_path, "/", "-")}-#{sanitize_name(item.name)}"
    end
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
