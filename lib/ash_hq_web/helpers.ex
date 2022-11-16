defmodule AshHqWeb.Helpers do
  @moduledoc "Simple helpers for doc liveviews"

  require Logger

  def latest_version(library) do
    case library.versions do
      [] ->
        nil

      versions ->
        Enum.min(versions, &(Version.compare(&1.version, &2.version) != :lt))
    end
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

  def render_replacements(libraries, selected_versions, docs) do
    Spark.DocIndex.render_replacements(
      docs,
      %{
        code_block: ~r/<code class="makeup elixir highlight">[\s\S]*?(?=<\/code>)/
      },
      fn
        :mix_dep, %{text: text, library: library}, context ->
          dep = render_mix_dep(libraries, library, selected_versions, text)

          if context == :code_block do
            dep
          else
            "<pre><code>#{dep}</code></pre>"
          end

        :link, %{type: "option", item: item, name_override: name, library: library}, _ ->
          path =
            item
            |> String.trim_leading("/")
            |> String.split(~r/[\/\.]/)
            |> Enum.drop(1)

          name = name || join_path(path)

          dsl_path = path |> :lists.droplast() |> Enum.map_join("/", &sanitize_name/1)
          anchor = path |> List.last() |> sanitize_name()

          ~s(<a href="/docs/dsl/#{library}/#{version(libraries, library, selected_versions)}/#{dsl_path}##{anchor}">#{name}</a>)

        :link, %{type: "dsl", item: item, name_override: name, library: library}, _ ->
          path =
            item
            |> String.trim_leading("/")
            |> String.split(~r/[\/\.]/)
            |> Enum.drop(1)

          dsl_path = Enum.map_join(path, "/", &sanitize_name/1)

          name = name || join_path(path)

          ~s(<a href="/docs/dsl/#{library}/#{version(libraries, library, selected_versions)}/#{dsl_path}">#{name}</a>)

        :link, %{type: "extension", item: item, name_override: name, library: library}, _ ->
          ~s(<a href="/docs/dsl/#{library}/#{version(libraries, library, selected_versions)}/#{sanitize_name(item)}">#{name || item}</a>)

        :link, %{type: "guide", item: item, name_override: name, library: library}, _ ->
          ~s(<a href="/docs/guides/#{library}/#{version(libraries, library, selected_versions)}/#{sanitize_name(item)}">#{name || item}</a>)

        :link, %{type: "module", item: item, name_override: name, library: library}, _ ->
          ~s(<a href="/docs/module/#{library}/#{version(libraries, library, selected_versions)}/#{sanitize_name(item)}">#{name || item}</a>)

        :link, %{type: "library", name_override: name, library: library}, _ ->
          ~s(<a href="/docs/#{library}/#{version(libraries, library, selected_versions)}">#{name || library}</a>)

        _, %{text: text}, _ ->
          raise "No link handler for: `#{text}`"
      end
    )
  end

  defp version(libraries, library, selected_versions) do
    libraries
    |> Enum.find(&(&1.name == library))
    |> case do
      nil ->
        "latest"

      library ->
        case selected_versions[library.id] do
          empty when empty in [nil, ""] ->
            "latest"

          id ->
            Enum.find(library.versions, &(&1.id == id)).version
        end
    end
  rescue
    _ ->
      "latest"
  end

  defp join_path(path) do
    Enum.join(path, " > ")
  end

  defp sanitize_name(name) do
    String.downcase(String.replace(name, ~r/[^A-Za-z0-9_]/, "-"))
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
            AshHqWeb.Helpers.latest_version(library)

          version ->
            version
        end
      end

    case Version.parse(version.version) do
      {:ok, %Version{pre: pre, build: build}}
      when pre != [] or not is_nil(build) ->
        ~s({:#{library.name}, "~> #{version.version}"})

      {:ok, %Version{major: major, minor: minor}} ->
        ~s({:#{library.name}, "~> #{major}.#{minor}"})
    end
  end
end
