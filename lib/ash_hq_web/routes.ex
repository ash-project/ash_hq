defmodule AshHqWeb.Routes do
  def guide_link(library, version, guide) do
    "/docs/guides/#{sanitize_name(library.name)}/#{sanitize_name(version)}/#{sanitize_name(guide)}"
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

  def doc_link(%AshHq.Docs.Guide{
        url_safe_name: url_safe_name,
        library_version: %{library_name: library_name, version: version}
      }) do
    "/docs/guides/#{sanitize_name(library_name)}/#{sanitize_name(version)}/#{url_safe_name}"
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
    case item.path do
      [] ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{sanitize_name(item.version_name)}/#{sanitize_name(item.extension_name)}##{sanitize_name(item.name)}"

      path ->
        "/docs/dsl/#{sanitize_name(item.library_name)}/#{sanitize_name(item.version_name)}/#{sanitize_name(item.extension_name)}##{Enum.map_join(path ++ [item.name], "-", &sanitize_name/1)}"
    end
  end

  def sanitize_name(name) do
    String.downcase(String.replace(name, ~r/[^A-Za-z0-9_]/, "-"))
  end
end
