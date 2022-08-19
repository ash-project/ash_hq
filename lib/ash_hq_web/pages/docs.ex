defmodule AshHqWeb.Pages.Docs do
  @moduledoc "The page for showing documentation"
  use Surface.Component

  alias AshHq.Docs.Extensions.RenderMarkdown
  alias AshHqWeb.Components.{CalloutText, DocSidebar, RightNav, Tag}
  alias AshHqWeb.DocRoutes
  alias Phoenix.LiveView.JS
  require Logger

  prop change_versions, :event, required: true
  prop selected_versions, :map, required: true
  prop libraries, :list, default: []
  prop uri, :string
  prop sidebar_state, :map, required: true
  prop collapse_sidebar, :event, required: true
  prop expand_sidebar, :event, required: true

  prop library, :any
  prop extension, :any
  prop docs, :any
  prop library_version, :any
  prop guide, :any
  prop doc_path, :list, default: []
  prop dsls, :list, default: []
  prop dsl, :any
  prop options, :list, default: []
  prop module, :any

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~F"""
    <div class="grid content-start overflow-hidden h-screen pb-12">
      <div class="xl:hidden flex flex-row justify-start space-x-12 items-center border-b border-t border-gray-600 py-3 mb-12">
        <button class="dark:hover:text-gray-600" phx-click={show_sidebar()}>
          <Heroicons.Outline.MenuIcon class="w-8 h-8 ml-4" />
        </button>
        {#if @doc_path && @doc_path != []}
          <div class="flex flex-row space-x-1 items-center">
            {#case @doc_path}
              {#match [item]}
                <div class="dark:text-white">
                  {item}
                </div>
              {#match path}
                {#for item <- :lists.droplast(path)}
                  <span class="text-gray-400">
                    {item}
                  </span>
                  <Heroicons.Outline.ChevronRightIcon class="w-3 h-3" />
                {/for}
                <span class="dark:text-white">
                  <CalloutText>{List.last(path)}</CalloutText>
                </span>
            {/case}
          </div>
        {/if}
      </div>
      <span class="grid overflow-hidden xl:hidden">
        <div
          id="mobile-sidebar-container"
          class="overflow-hidden hidden fixed w-min h-full transition bg-white dark:bg-primary-black"
        >
          <DocSidebar
            id="mobile-sidebar"
            libraries={@libraries}
            extension={@extension}
            sidebar_state={@sidebar_state}
            collapse_sidebar={@collapse_sidebar}
            expand_sidebar={@expand_sidebar}
            module={@module}
            guide={@guide}
            library={@library}
            library_version={@library_version}
            selected_versions={@selected_versions}
            dsl={@dsl}
          />
        </div>
      </span>
      <div class="grow w-full overflow-hidden flex flex-row h-full justify-center space-x-12 bg-white dark:bg-primary-black">
        <DocSidebar
          id="sidebar"
          class="hidden xl:block mt-10"
          module={@module}
          libraries={@libraries}
          extension={@extension}
          sidebar_state={@sidebar_state}
          collapse_sidebar={@collapse_sidebar}
          expand_sidebar={@expand_sidebar}
          guide={@guide}
          library={@library}
          library_version={@library_version}
          selected_versions={@selected_versions}
          dsl={@dsl}
        />
        <div
          id="docs-window"
          class="w-full prose prose-xl max-w-6xl dark:bg-primary-black dark:prose-invert overflow-y-auto overflow-x-visible pr-8 mt-14"
          phx-hook="Docs"
        >
          <div id="module-docs" class="w-full nav-anchor text-black dark:text-white relative">
            {#if @module}
              <h2>{@module.name}{render_source_code_link(assigns, @module, @library, @library_version)}</h2>
            {/if}
            {#if @library_version}
              <div class="absolute right-2 top-2 border rounded-lg flex flex-row">
                <div class="border-r pl-2 pr-2 dark:text-black bg-orange-600 dark:bg-orange-600 rounded-l-lg">
                  {@library.name}
                </div>
                <div class="pl-2 pr-2 rounded-r-lg bg-gray-300 dark:bg-inherit">
                  {@library_version.version}
                </div>
              </div>
            {/if}
            {raw(render_replacements(assigns, @docs))}
            {#if @dsl}
              {#for {category, links} <- @dsl.links || %{}}
                <h3>{String.capitalize(category)}</h3>
                <ul>
                  {#for link <- links}
                    <li>
                      {raw(render_links("{{link:#{link}}}", assigns))}
                    </li>
                  {/for}
                </ul>
              {/for}
            {/if}
          </div>
          {#if @module}
            {render_functions(assigns, @module.functions, :callback, "Callbacks")}
            {render_functions(assigns, @module.functions, :function, "Functions")}
            {render_functions(assigns, @module.functions, :macro, "Macros")}
          {/if}
          {#case modules_in_scope(@dsl, @extension, @libraries, @selected_versions)}
            {#match []}
            {#match imports}
              <h3>Imported Modules</h3>
              {#for mod <- imports}
                <ul>
                  <li>
                    <a href={DocRoutes.doc_link(mod, @selected_versions)}>{mod.name}</a>
                  </li>
                </ul>
              {/for}
          {/case}
          {#case child_dsls(@extension, @dsl)}
            {#match []}
            {#match children}
              <h3>
                Nested DSLs
              </h3>
              <ul>
                {#for child <- children}
                  <li>
                    <a href={DocRoutes.doc_link(child, @selected_versions)}>{child.name}</a>
                  </li>
                {/for}
              </ul>
          {/case}
          <div class="ml-2">
            <table>
              {#if !Enum.empty?(@options)}
                {#if Enum.any?(@options, & &1.argument_index)}
                  <td colspan="100%">
                    <h3>
                      Arguments
                    </h3>
                  </td>
                  <tr>
                    <th>Name</th>
                    <th>Type</th>
                    <th>Doc</th>
                    <th>Links</th>
                  </tr>
                  {#for option <- positional_options(@options)}
                    <tr id={option.sanitized_path}>
                      <td>
                        <div class="flex flex-row items-baseline">
                          <a href={"##{option.sanitized_path}"}>
                            <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                          </a>
                          <div class="flex flex-row space-x-2">
                            <CalloutText>{option.name}</CalloutText>
                            {render_tags(assigns, option)}
                          </div>
                        </div>
                      </td>
                      <td>
                        {option.type}
                      </td>
                      <td>
                        {raw(render_replacements(assigns, RenderMarkdown.as_html!(option.html_for)))}
                      </td>
                      <td>
                        {raw(
                          Enum.map_join(
                            List.flatten(Map.values(option.links || %{})),
                            ", ",
                            &render_links("{{link:#{&1}}}", assigns)
                          )
                        )}
                      </td>
                    </tr>
                  {/for}
                {/if}
                <tr>
                  <td colspan="100%">
                    <h3>
                      Options
                    </h3>
                  </td>
                </tr>
                <tr>
                  <th>Name</th>
                  <th>Type</th>
                  <th>Doc</th>
                  <th>Links</th>
                </tr>
                {#for %{argument_index: nil} = option <- @options}
                  <tr id={option.sanitized_path}>
                    <td>
                      <div class="flex flex-row items-baseline">
                        <a href={"##{option.sanitized_path}"}>
                          <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                        </a>
                        <CalloutText>{option.name}</CalloutText>
                        {render_tags(assigns, option)}
                      </div>
                    </td>
                    <td>
                      {option.type}
                    </td>
                    <td>
                      {raw(render_replacements(assigns, RenderMarkdown.as_html!(option.html_for)))}
                    </td>
                    <td>
                      {raw(
                        Enum.map_join(
                          List.flatten(Map.values(option.links || %{})),
                          ", ",
                          &render_links("{{link:#{&1}}}", assigns)
                        )
                      )}
                    </td>
                  </tr>
                {/for}
              {/if}
            </table>
          </div>
        </div>
        {#if @module}
          <div class="w-min overflow-y-auto overflow-x-visible mt-14 dark:bg-primary-black bg-opacity-70">
            <RightNav functions={@module.functions} module={@module.name} />
          </div>
        {#else}
          <div />
        {/if}
      </div>
    </div>
    """
  end

  defp render_source_code_link(assigns, module_or_function, library, library_version) do
    ~F"""
    {#if module_or_function.file}
      <a target="_blank" href={source_link(module_or_function, library, library_version)}>{"</>"}</a>
    {/if}
    """
  end

  defp modules_in_scope(nil, _, _, _), do: []
  defp modules_in_scope(_, nil, _, _), do: []

  defp modules_in_scope(dsl, %{dsls: dsls}, libraries, selected_versions) do
    dsl_path = dsl.path ++ [dsl.name]

    dsls
    |> Enum.filter(fn potential_parent ->
      List.starts_with?(dsl_path, potential_parent.path ++ [potential_parent.name])
    end)
    |> Enum.flat_map(fn dsl ->
      dsl.imports || []
    end)
    |> Enum.flat_map(fn mod_name ->
      case find_module(libraries, selected_versions, mod_name) do
        nil ->
          Logger.warn("No such module found called #{inspect(mod_name)}")
          []

        module ->
          [module]
      end
    end)
  end

  defp find_module(libraries, selected_versions, mod_name) do
    Enum.find_value(libraries, fn library ->
      Enum.find_value(library.versions, fn version ->
        if version.id == selected_versions[library.id] do
          Enum.find(version.modules, &(&1.name == mod_name))
        end
      end)
    end)
  end

  defp child_dsls(_, nil), do: []
  defp child_dsls(nil, _), do: []

  defp child_dsls(%{dsls: dsls}, dsl) do
    dsl_path = dsl.path ++ [dsl.name]
    dsl_path_count = Enum.count(dsl_path)

    Enum.filter(dsls, fn potential_child ->
      potential_child_path = potential_child.path ++ [potential_child.name]

      List.starts_with?(potential_child_path, dsl_path) &&
        Enum.count(potential_child_path) - dsl_path_count == 1
    end)
  end

  defp positional_options(options) do
    options
    |> Enum.filter(& &1.argument_index)
    |> Enum.sort_by(& &1.argument_index)
  end

  defp render_functions(assigns, functions, type, header) do
    ~F"""
    {#case Enum.filter(functions, &(&1.type == type))}
      {#match []}
      {#match functions}
        <h1>{header}</h1>
        {#for function <- functions}
          <div class="rounded-lg bg-slate-400 dark:bg-slate-700 bg-opacity-50 px-2">
            <p class="">
              <div class="">
                <div class="flex flex-row items-baseline">
                  <a href={"##{type}-#{function.sanitized_name}-#{function.arity}"}>
                    <Heroicons.Outline.LinkIcon class="h-3 m-3" />
                  </a>
                  <div
                    class="nav-anchor text-xl font-semibold mb-2"
                    id={"#{type}-#{function.sanitized_name}-#{function.arity}"}
                  >{function.name}/{function.arity} {render_source_code_link(assigns, function, @library, @library_version)}</div>
                </div>
              </div>
              {#for head <- function.heads}
                <code class="makeup elixir">{head}</code>
              {/for}
              {raw(render_replacements(assigns, RenderMarkdown.as_html!(function.html_for, false)))}
            </p>
          </div>
        {/for}
    {/case}
    """
  end

  defp source_link(%AshHq.Docs.Module{file: file}, library, library_version) do
    "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}"
  end

  defp source_link(%AshHq.Docs.Function{file: file, line: line}, library, library_version) do
    if line do
      "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}#L#{line}"
    else
      "https://github.com/ash-project/#{library.name}/tree/#{library_version.version}/#{file}"
    end
  end

  def path_to_name(path, name) do
    Enum.map_join(path ++ [name], "-", &DocRoutes.sanitize_name/1)
  end

  defp render_tags(assigns, option) do
    ~F"""
    {#if option.required}
      <Tag color={:red}>
        Required
      </Tag>
    {/if}
    """
  end

  def show_sidebar(js \\ %JS{}) do
    js
    |> JS.toggle(
      to: "#mobile-sidebar-container",
      in: {
        "transition ease-in duration-100",
        "opacity-0",
        "opacity-100"
      },
      out: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
    )
  end

  defp render_replacements(_assigns, nil), do: ""

  defp render_replacements(assigns, docs) do
    docs
    |> render_links(assigns)
    |> render_mix_deps(assigns)
  end

  defp render_mix_deps(docs, assigns) do
    String.replace(docs, ~r/{{mix_dep:.*}}/, fn text ->
      try do
        "{{mix_dep:" <> library = String.trim_trailing(text, "}}")

        "<pre><code>#{render_mix_dep(assigns, library, text)}</code></pre>"
      rescue
        e ->
          Logger.error("Invalid link #{inspect(e)}")
          text
      end
    end)
  end

  defp render_mix_dep(assigns, library, source) do
    library =
      Enum.find(assigns[:libraries], &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    selected_versions = assigns[:selected_versions]

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
      {:ok, %{major: major, minor: minor, patch: 0}} ->
        ~s({:#{library.name}, "~> #{major}.#{minor}"})

      {:ok, version} ->
        ~s({:#{library.name}, "~> #{version}"})
    end
  end

  defp render_links(docs, assigns) do
    String.replace(docs, ~r/(?!<code>){{link:.*}}(?!<\/code>)/, fn text ->
      try do
        "{{link:" <> rest = String.trim_trailing(text, "}}")
        [library, type, item | rest] = String.split(rest, ":")
        render_link(assigns, library, type, item, text, rest)
      rescue
        e ->
          Logger.error("Invalid link #{inspect(e)}")
          text
      end
    end)
  end

  defp render_link(assigns, library, type, item, source, rest) do
    library =
      Enum.find(assigns[:libraries], &(&1.name == library)) ||
        raise "No such library in link: #{source}"

    selected_versions = assigns[:selected_versions]

    version =
      if selected_versions[library.id] in ["latest", nil, ""] do
        Enum.find(library.versions, &String.contains?(&1.version, ".")) ||
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
          <a href="#{DocRoutes.doc_link(guide, assigns[:selected_versions])}">#{text}</a>
          """

        "dsl" ->
          name =
            item
            |> String.split("/")
            |> Enum.join(".")

          """
          <a href="/docs/dsl/#{library.name}/#{version.version}/#{item}">#{name}</a>
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
