defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias AshHqWeb.Components.TreeView
  alias AshHqWeb.Components.DocSidebarDslItems
  alias Phoenix.LiveView.JS

  prop class, :css_class, default: ""
  prop libraries, :list, required: true
  prop extension, :any, default: nil
  prop guide, :any, default: nil
  prop library, :any, default: nil
  prop library_version, :any, default: nil
  prop selected_versions, :map, default: %{}
  prop id, :string, required: true
  prop dsl, :any, required: true
  prop module, :any, required: true
  prop mix_task, :any, required: true
  prop add_version, :event, required: true
  prop remove_version, :event, required: true
  prop change_version, :event, required: true

  data guides_by_category_and_library, :any
  data extensions, :any
  data modules_by_category, :any
  data mix_tasks_by_category, :any

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    selected_versions =
      if assigns[:library_version] do
        Map.put(
          assigns[:selected_versions] || %{},
          assigns[:library_version].library_id,
          assigns[:library_version].id
        )
      else
        assigns[:selected_versions]
      end

    assigns = assign(assigns, :selected_versions, selected_versions)

    assigns =
      assign(
        assigns,
        guides_by_category_and_library:
          guides_by_category_and_library(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          ),
        extensions:
          get_extensions(
            assigns[:libraries],
            assigns[:library_versions],
            assigns[:selected_versions]
          ),
        modules_by_category:
          modules_by_category(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          ),
        mix_tasks_by_category:
          mix_tasks_by_category(
            assigns[:libraries],
            assigns[:library_version],
            assigns[:selected_versions]
          )
      )

    ~F"""
    <aside
      id={@id}
      class={"grid h-screen overflow-y-auto pb-36 w-fit z-40 bg-white dark:bg-base-dark-850", @class}
      aria-label="Sidebar"
    >
      <button class="hidden" id={"#{@id}-hide"} phx-click={hide_sidebar()} />
      <div class="flex flex-col">
        <div class="text-black dark:text-white font-light w-full px-2 mb-2">
          Including Packages:
        </div>
        <AshHqWeb.Components.VersionPills
          id={"#{@id}-version-pills"}
          libraries={@libraries}
          remove_version={@remove_version}
          selected_versions={@selected_versions}
        />
      </div>
      <TreeView id={"#{@id}-treeview"}>
        <TreeView.Item name="guides" text="Guides">
          <TreeView.Item
            :for={{category, by_library} <- @guides_by_category_and_library}
            name={slug(category)}
            text={category}
            collapsable
            class="text-base-light-500"
          >
            <TreeView.Item
              :for={{library, guides} <- by_library}
              name={slug(library)}
              text={library}
              collapsable
              class="text-base-light-500"
            >
              <TreeView.Item
                :for={guide <- guides}
                name={slug(guide.name)}
                text={guide.name}
                icon={render_icon(assigns, "Guide")}
                selected={@guide && @guide.id == guide.id}
                on_click={JS.patch(DocRoutes.doc_link(guide, @selected_versions))}
                class="text-base-light-900 dark:text-base-dark-200"
              >
              </TreeView.Item>
            </TreeView.Item>
          </TreeView.Item>
        </TreeView.Item>

        <TreeView.Item name="reference" text="Reference">
          <TreeView.Item
            name="extensions"
            text="Extensions"
            collapsable
            collapsed={!@extension}
            class="text-base-light-500"
          >
            <TreeView.Item
              :for={{library, extensions} <- @extensions}
              name={slug(library)}
              text={library}
              collapsable
              class="text-base-light-400"
            >
              <TreeView.Item
                :for={extension <- extensions}
                name={slug(extension.name)}
                text={extension.name}
                icon={render_icon(assigns, extension.type)}
                collapsable={extension.dsls != []}
                collapsed={!(@extension && @extension.id == extension.id)}
                on_click={JS.patch(DocRoutes.doc_link(extension, @selected_versions))}
                selected={@extension && !@dsl && @extension.id == extension.id}
                indent_guide
                class="text-base-light-900 dark:text-base-dark-200"
              >
                <DocSidebarDslItems
                  selected_versions={@selected_versions}
                  dsls={extension.dsls}
                  dsl={@dsl}
                  dsl_path={[]}
                />
              </TreeView.Item>
            </TreeView.Item>
          </TreeView.Item>

          <TreeView.Item
            name="mix-tasks"
            text="Mix Tasks"
            collapsable
            collapsed={!@mix_task}
            class="text-base-light-500"
          >
            <TreeView.Item
              :for={{category, mix_tasks} <- @mix_tasks_by_category}
              name={slug(category)}
              text={category}
              collapsable
              class="text-base-light-400"
            >
              <TreeView.Item
                :for={mix_task <- mix_tasks}
                name={slug(mix_task.name)}
                text={mix_task.name}
                icon={render_icon(assigns, "Mix Task")}
                on_click={JS.patch(DocRoutes.doc_link(mix_task, selected_versions))}
                selected={@mix_task && @mix_task.id == mix_task.id}
                class="text-base-light-900 dark:text-base-dark-200"
              />
            </TreeView.Item>
          </TreeView.Item>
          <TreeView.Item
            name="modules"
            text="Modules"
            collapsable
            collapsed={!@module}
            class="text-base-light-500"
          >
            <TreeView.Item
              :for={{category, modules} <- @modules_by_category}
              name={slug(category)}
              text={category}
              collapsable
              class="text-base-light-400"
            >
              <TreeView.Item
                :for={module <- modules}
                name={slug(module.name)}
                text={module.name}
                icon={render_icon(assigns, "Code")}
                on_click={JS.patch(DocRoutes.doc_link(module, @selected_versions))}
                selected={@module && @module.id == module.id}
                class="text-base-light-900 dark:text-base-dark-200"
              >
              </TreeView.Item>
            </TreeView.Item>
          </TreeView.Item>
        </TreeView.Item>
      </TreeView>
    </aside>
    """
  end

  def render_icon(assigns, "Guide") do
    ~F"""
    <Heroicons.Outline.BookOpenIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Resource") do
    ~F"""
    <Heroicons.Outline.ServerIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Api") do
    ~F"""
    <Heroicons.Outline.SwitchHorizontalIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "DataLayer") do
    ~F"""
    <Heroicons.Outline.DatabaseIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Flow") do
    ~F"""
    <Heroicons.Outline.MapIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Notifier") do
    ~F"""
    <Heroicons.Outline.MailIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Registry") do
    ~F"""
    <Heroicons.Outline.ViewListIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, "Mix Task") do
    ~F"""
    <Heroicons.Outline.TerminalIcon class="h-4 w-4 flex-none" />
    """
  end

  def render_icon(assigns, _) do
    ~F"""
    <Heroicons.Outline.PuzzleIcon class="h-4 w-4 flex-none" />
    """
  end

  def hide_sidebar(js \\ %JS{}) do
    js
    |> JS.hide(
      to: "#mobile-sidebar-container",
      transition: {
        "transition ease-out duration-75",
        "opacity-100",
        "opacity-0"
      }
    )
  end

  defp selected_version(library, library_version, selected_versions) do
    selected_version = selected_versions[library.id]

    if library_version && library_version.library_id == library.id do
      library_version
    else
      if selected_version == "latest" do
        AshHqWeb.Helpers.latest_version(library)
      else
        if selected_version not in [nil, ""] do
          Enum.find(library.versions, &(&1.id == selected_version))
        end
      end
    end
  end

  @start_guides ["Tutorials", "Topics", "How To", "Misc"]

  defp guides_by_category_and_library(libraries, library_version, selected_versions) do
    libraries =
      Enum.filter(libraries, fn library ->
        selected_versions[library.id] && selected_versions[library.id] != ""
      end)

    library_name_to_order =
      libraries
      |> Enum.sort_by(& &1.order)
      |> Enum.map(& &1.display_name)

    libraries
    |> Enum.flat_map(fn library ->
      library
      |> selected_version(library_version, selected_versions)
      |> case do
        nil ->
          []

        %{guides: guides} ->
          Enum.map(guides, &{&1, library.display_name})
      end
    end)
    |> Enum.group_by(fn {guide, _} ->
      guide.category
    end)
    |> Enum.map(fn {category, guides} ->
      guides_by_library =
        library_name_to_order
        |> Enum.map(fn name ->
          {name,
           Enum.flat_map(guides, fn {guide, guide_lib_name} ->
             if name == guide_lib_name do
               [guide]
             else
               []
             end
           end)}
        end)
        |> Enum.reject(fn {_, guides} ->
          Enum.empty?(guides)
        end)

      {category, guides_by_library}
    end)
    |> partially_alphabetically_sort(@start_guides, [])
  end

  defp get_extensions(libraries, library_version, selected_versions) do
    libraries
    |> Enum.sort_by(& &1.order)
    |> Enum.map(&{&1.display_name, selected_version(&1, library_version, selected_versions)})
    |> Enum.filter(&elem(&1, 1))
    |> Enum.flat_map(fn {name, version} ->
      case version.extensions do
        [] ->
          []

        %Ash.NotLoaded{} ->
          raise "extensions not selected for #{version.version} | #{version.id} of #{name}"

        extensions ->
          [{name, extensions}]
      end
    end)
  end

  @last_categories ["Errors"]

  defp modules_by_category(libraries, library_version, selected_versions) do
    libraries
    |> Enum.map(&selected_version(&1, library_version, selected_versions))
    |> Enum.filter(& &1)
    |> Enum.flat_map(& &1.modules)
    |> Enum.group_by(fn module ->
      module.category
    end)
    |> Enum.sort_by(fn {category, _} -> category end)
    |> Enum.map(fn {category, modules} ->
      {category, Enum.sort_by(modules, & &1.name)}
    end)
    |> partially_alphabetically_sort([], [])
  end

  defp mix_tasks_by_category(libraries, library_version, selected_versions) do
    libraries
    |> Enum.map(&selected_version(&1, library_version, selected_versions))
    |> Enum.filter(& &1)
    |> Enum.flat_map(& &1.mix_tasks)
    |> Enum.group_by(fn mix_task ->
      mix_task.category
    end)
    |> Enum.sort_by(fn {category, _} -> category end)
    |> Enum.map(fn {category, mix_tasks} ->
      {category, Enum.sort_by(mix_tasks, & &1.name)}
    end)
    |> partially_alphabetically_sort([], @last_categories)
  end

  defp partially_alphabetically_sort(keyed_list, first, last) do
    {first_items, rest} =
      Enum.split_with(keyed_list, fn {key, _} ->
        key in first
      end)

    {last_items, rest} =
      Enum.split_with(rest, fn {key, _} ->
        key in last
      end)

    first_items
    |> Enum.sort_by(fn {key, _} ->
      Enum.find_index(first, &(&1 == key))
    end)
    |> Enum.concat(Enum.sort_by(rest, &elem(&1, 0)))
    |> Enum.concat(
      Enum.sort_by(last_items, fn {key, _} ->
        Enum.find_index(last, &(&1 == key))
      end)
    )
  end

  def slug(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9-_]/, "-")
  end
end
