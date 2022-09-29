defmodule AshHqWeb.Helpers do
  @moduledoc "Simple helpers for doc liveviews"

  require Logger

  alias AshHqWeb.DocRoutes

  def latest_version(library) do
    library.versions
    |> Enum.min(&(Version.compare(&1.version, &2.version) != :lt))
  end

  def source_link(%AshHq.Docs.Module{file: file}, library, library_version) do
    "https://github.com/ash-project/#{library.name}/tree/v#{library_version.version}/#{file}"
  end

  def source_link(%AshHq.Docs.MixTask{file: file}, library, library_version) do
    "https://github.com/ash-project/#{library.name}/tree/v#{library_version.version}/#{file}"
  end

  def source_link(%AshHq.Docs.Function{file: file, line: line}, library, library_version) do
    if line do
      "https://github.com/ash-project/#{library.name}/tree/v#{library_version.version}/#{file}#L#{line}"
    else
      "https://github.com/ash-project/#{library.name}/tree/v#{library_version.version}/#{file}"
    end
  end

  def render_replacements(_, _, nil), do: ""

  def render_replacements(libraries, selected_versions, docs) do
    docs
    |> render_links(libraries, selected_versions)
    |> render_mix_deps(libraries, selected_versions)
  end

  defp render_mix_deps(docs, libraries, selected_versions) do
    String.replace(docs, ~r/(?!<code>){{mix_dep:.*}}(?!<\/code>)/, fn text ->
      try do
        "{{mix_dep:" <> library = String.trim_trailing(text, "}}")

        "<pre><code>#{render_mix_dep(libraries, library, selected_versions, text)}</code></pre>"
      rescue
        e ->
          Logger.error(
            "Invalid link #{Exception.format(:error, e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
          )

          text
      end
    end)
  end

  defp render_mix_dep(libraries, library, selected_versions, source) do
    library =
      Enum.find(libraries, &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    version =
      if selected_versions[library.id] == "latest" do
        AshHqWeb.Helpers.latest_version(library)
      else
        case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
          nil ->
            nil

          version ->
            version
        end
      end

    case Version.parse(version.version) do
      {:ok, %Version{pre: pre, build: build}}
      when not is_nil(pre) or not is_nil(build) ->
        ~s({:#{library.name}, "~> #{version.version}"})

      {:ok, %Version{major: major, minor: minor, patch: 0}} ->
        ~s({:#{library.name}, "~> #{major}.#{minor}"})

      {:ok, version} ->
        ~s({:#{library.name}, "~> #{version.version}"})
    end
  end

  def render_links(docs, libraries, selected_versions) do
    String.replace(docs, ~r/(?!<code>){{link:[^}]*}}(?!<\/code>)/, fn text ->
      try do
        "{{link:" <> rest = String.trim_trailing(text, "}}")
        [library, type, item | rest] = String.split(rest, ":")
        render_link(libraries, selected_versions, library, type, item, text, rest)
      rescue
        e ->
          Logger.error(
            "Invalid link #{Exception.format(:error, e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
          )

          text
      end
    end)
  end

  defp render_link(libraries, selected_versions, library, type, item, source, rest) do
    library =
      Enum.find(libraries, &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    version =
      if selected_versions[library.id] in ["latest", nil, ""] do
        AshHqWeb.Helpers.latest_version(library)
      else
        case Enum.find(library.versions, &(&1.id == selected_versions[library.id])) do
          nil ->
            nil

          version ->
            version
        end
      end

    if is_nil(version) do
      raise "no version for library"
    else
      case type do
        "guide" ->
          guide =
            Enum.find(version.guides, &(&1.name == item)) ||
              raise "No such guide in link: #{source}"

          text = Enum.at(rest, 0) || item

          """
          <a href="#{DocRoutes.doc_link(guide, selected_versions)}">#{text}</a>
          """

        "dsl" ->
          path =
            item
            |> String.split(~r/[\/\.]/)

          name =
            path
            |> Enum.join(".")

          route = Enum.map_join(path, "/", &DocRoutes.sanitize_name/1)

          """
          <a href="/docs/dsl/#{library.name}/#{version.version}/#{route}">#{name}</a>
          """

        "option" ->
          path =
            item
            |> String.split(~r/[\/\.]/)

          name = Enum.join(path, ".")

          dsl_path = path |> :lists.droplast() |> Enum.map_join("/", &DocRoutes.sanitize_name/1)
          anchor = path |> Enum.map_join("/", &DocRoutes.sanitize_name/1)

          """
          <a href="/docs/dsl/#{library.name}/#{version.version}/#{dsl_path}##{anchor}">#{name}</a>
          """

        "module" ->
          """
          <a href="/docs/module/#{library.name}/#{version.version}/#{DocRoutes.sanitize_name(item)}">#{item}</a>
          """

        "extension" ->
          """
          <a href="/docs/dsl/#{library.name}/#{version.version}/#{DocRoutes.sanitize_name(item)}">#{item}</a>
          """

        type ->
          raise "unimplemented link type #{inspect(type)} in #{source}"
      end
    end
  end
end
