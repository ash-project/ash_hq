defmodule AshHqWeb.Routes do
  def guide_link(library, version, route) do
    "/docs/guides/#{sanitize_name(library.name)}/#{sanitize_name(version)}/#{route}"
  end

  def library_link(library, nil) do
    "/docs/dsl/#{sanitize_name(library.name)}"
  end

  def library_link(library, name) do
    "/docs/dsl/#{sanitize_name(library.name)}/#{sanitize_name(name)}"
  end

  def extension_link(library, name, extension) do
    "/docs/dsl/#{sanitize_name(library.name)}/#{sanitize_name(name)}/#{sanitize_name(extension)}"
  end

  def dsl_link(library, name, extension, item) do
    case item do
      %AshHq.Docs.Dsl{} = item ->
        "/docs/dsl/#{sanitize_name(library.name)}/#{sanitize_name(name)}/#{sanitize_name(extension)}/#{Enum.map_join(item.path ++ [item.name], "/", &sanitize_name/1)}"

      %AshHq.Docs.Option{} = item ->
        "/docs/dsl/#{sanitize_name(library.name)}/#{sanitize_name(name)}/#{sanitize_name(extension)}/#{Enum.map_join(item.path, "/", &sanitize_name/1)}##{item.name}"
    end
  end

  def module_link(library, version, module) do
    "/docs/module/#{sanitize_name(library.name)}/#{sanitize_name(version)}/#{sanitize_name(module)}"
  end

  def doc_link(%AshHq.Docs.Module{
        name: name,
        library_name: library_name,
        version_name: version_name
      }) do
    "/docs/module/#{sanitize_name(library_name)}/#{sanitize_name(version_name)}/#{sanitize_name(name)}"
  end

  def doc_link(%AshHq.Docs.Function{
        name: name,
        arity: arity,
        type: type,
        module_name: module_name,
        library_name: library_name,
        version_name: version_name
      }) do
    "/docs/module/#{sanitize_name(library_name)}/#{sanitize_name(version_name)}/#{sanitize_name(module_name)}/##{type}-#{sanitize_name(name)}-#{arity}"
  end

  def doc_link(%AshHq.Docs.Guide{
        route: route,
        library_version: %{library_name: library_name, version: version}
      }) do
    "/docs/guides/#{sanitize_name(library_name)}/#{sanitize_name(version)}/#{route}"
  end

  def doc_link(%AshHq.Docs.LibraryVersion{library_name: library_name, version: version}) do
    "/docs/dsl/#{sanitize_name(library_name)}/#{sanitize_name(version)}"
  end

  def doc_link(%AshHq.Docs.Extension{
        library_version: %{library_name: library_name, version: version},
        name: name
      }) do
    "/docs/dsl/#{sanitize_name(library_name)}/#{sanitize_name(version)}/#{sanitize_name(name)}"
  end

  def doc_link(item) do
    case item do
      %AshHq.Docs.Dsl{} = item ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{sanitize_name(item.version_name)}/#{sanitize_name(item.extension_name)}/#{Enum.map_join(item.path ++ [item.name], "/", &sanitize_name/1)}"

      %AshHq.Docs.Option{} = item ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{sanitize_name(item.version_name)}/#{sanitize_name(item.extension_name)}/#{Enum.map_join(item.path, "/", &sanitize_name/1)}##{item.name}"
    end
  end

  def sanitize_name(name) do
    String.downcase(String.replace(name, ~r/[^A-Za-z0-9_]/, "-"))
  end
end
