defmodule AshHqWeb.Routes do
  def library_link(library, name) do
    "/docs/dsl/#{library.name}/#{name}"
  end

  def extension_link(library, name, extension) do
    "/docs/dsl/#{library.name}/#{name}/#{extension}"
  end

  def doc_link(%AshHq.Docs.LibraryVersion{library_name: library_name, version: version}) do
    "/docs/dsl/#{library_name}/#{version}"
  end

  def doc_link(item) do
    case item.path do
      [] ->
        "/docs/dsl/#{item.library_name}/#{item.version_name}/#{item.extension_name}"

      path ->
        "/docs/dsl/#{item.library_name}/#{item.version_name}/#{item.extension_name}?path=#{Enum.join(path, ".")}"
    end
  end
end
