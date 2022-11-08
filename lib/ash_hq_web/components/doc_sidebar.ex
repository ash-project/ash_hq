defmodule AshHqWeb.Components.DocSidebar do
  @moduledoc "The left sidebar of the docs pages"
  use Surface.Component

  alias AshHqWeb.DocRoutes
  alias AshHqWeb.Components.TreeView
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
      <TreeView
        id={"#{@id}-sidebar-treeview"}
        render_icon={&icon/1}
        items={treeview_items(
          @selected_versions,
          @guide,
          @extension,
          @dsl,
          @mix_task,
          @module,
          @guides_by_category_and_library,
          @extensions,
          @mix_tasks_by_category,
          @modules_by_category
        )}
      />
    </aside>
    """
  end

  def icon(assigns) do
    ~F"""
    {#case @name}
      {#match "Guide"}
        <Heroicons.Outline.BookOpenIcon class={@class} />
      {#match "Resource"}
        <Heroicons.Outline.ServerIcon class={@class} />
      {#match "Api"}
        <Heroicons.Outline.SwitchHorizontalIcon class={@class} />
      {#match "DataLayer"}
        <Heroicons.Outline.DatabaseIcon class={@class} />
      {#match "Flow"}
        <Heroicons.Outline.MapIcon class={@class} />
      {#match "Notifier"}
        <Heroicons.Outline.MailIcon class={@class} />
      {#match "Registry"}
        <Heroicons.Outline.ViewListIcon class={@class} />
      {#match "Code"}
        <Heroicons.Outline.CodeIcon class={@class} />
      {#match "Mix Task"}
        <Heroicons.Outline.TerminalIcon class={@class} />
      {#match _}
        <Heroicons.Outline.PuzzleIcon class={@class} />
    {/case}
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

  defp treeview_items(
         selected_versions,
         selected_guide,
         selected_extension,
         selected_dsl,
         selected_mix_task,
         selected_module,
         guides_by_category_and_library,
         extensions,
         mix_tasks_by_category,
         modules_by_category
       ) do
    text_styles = "text-base-light-900 dark:text-base-dark-200"

    guides = %TreeView.Item{
      name: "guides",
      label: "Guides",
      collapsable: false,
      items:
        Enum.map(guides_by_category_and_library, fn {category, by_library} ->
          %TreeView.Item{
            name: slug(category),
            label: category,
            collapsable: true,
            class: "text-base-light-500",
            items:
              Enum.map(by_library, fn {library, guides} ->
                %TreeView.Item{
                  name: slug(library),
                  label: library,
                  collapsable: true,
                  class: "text-base-light-400",
                  items:
                    Enum.map(guides, fn guide ->
                      %TreeView.Item{
                        name: slug(guide.name),
                        label: guide.name,
                        icon: "Guide",
                        selected: selected_guide && selected_guide.id == guide.id,
                        link: [patch: DocRoutes.doc_link(guide, selected_versions)],
                        class: text_styles
                      }
                    end)
                }
              end)
          }
        end)
    }

    extensions = %TreeView.Item{
      name: "extensions",
      label: "Extensions",
      collapsable: true,
      collapsed: !selected_extension,
      class: "text-base-light-500",
      items:
        Enum.map(extensions, fn {library, extensions} ->
          %TreeView.Item{
            name: slug(library),
            label: library,
            collapsable: true,
            class: "text-base-light-400",
            items:
              Enum.map(extensions, fn extension ->
                items = dsl_tree_view_items(selected_versions, extension.dsls, selected_dsl, [])

                %TreeView.Item{
                  name: slug(extension.name),
                  label: extension.name,
                  icon: extension.type,
                  collapsable: items != [],
                  collapsed: !(selected_extension && selected_extension.id == extension.id),
                  link: [patch: DocRoutes.doc_link(extension, selected_versions)],
                  selected: (selected_extension && !selected_dsl) && selected_extension.id == extension.id,
                  items: items,
                  indent_guide: true,
                  class: text_styles
                }
              end)
          }
        end)
    }

    mix_tasks = %TreeView.Item{
      name: "mix-tasks",
      label: "Mix Tasks",
      collapsable: true,
      collapsed: !selected_mix_task,
      class: "text-base-light-500",
      items:
        Enum.map(mix_tasks_by_category, fn {category, mix_tasks} ->
          %TreeView.Item{
            name: slug(category),
            label: category,
            collapsable: true,
            class: "text-base-light-400",
            items:
              Enum.map(mix_tasks, fn mix_task ->
                %TreeView.Item{
                  name: slug(mix_task.name),
                  label: mix_task.name,
                  icon: "Mix Task",
                  link: [patch: DocRoutes.doc_link(mix_task, selected_versions)],
                  selected: selected_mix_task && selected_mix_task.id == mix_task.id,
                  class: text_styles
                }
              end)
          }
        end)
    }

    modules = %TreeView.Item{
      name: "modules",
      label: "Modules",
      collapsable: true,
      collapsed: !selected_module,
      class: "text-base-light-500",
      items:
        Enum.map(modules_by_category, fn {category, modules} ->
          %TreeView.Item{
            name: slug(category),
            label: category,
            collapsable: true,
            class: "text-base-light-400",
            items:
              Enum.map(modules, fn module ->
                %TreeView.Item{
                  name: slug(module.name),
                  label: module.name,
                  icon: "Code",
                  link: [patch: DocRoutes.doc_link(module, selected_versions)],
                  selected: selected_module && selected_module.id == module.id,
                  class: text_styles
                }
              end)
          }
        end)
    }

    reference = %TreeView.Item{
      name: "reference",
      label: "Reference",
      collapsable: false,
      items: [
        extensions,
        mix_tasks,
        modules
      ]
    }

    [
      guides,
      reference
    ]
  end

  defp dsl_tree_view_items(selected_versions, dsls, selected_dsl, path) do
    dsls
    |> Enum.filter(&(&1.path == path))
    |> Enum.map(fn dsl ->
      items = dsl_tree_view_items(selected_versions, dsls, selected_dsl, path ++ [dsl.name])

      %TreeView.Item{
        name: slug(dsl.name),
        label: dsl.name,
        collapsable: false,
        selected: selected_dsl && selected_dsl.id == dsl.id,
        link: [patch: DocRoutes.doc_link(dsl, selected_versions)],
        items: items,
        indent_guide: true
      }
    end)
  end

  def slug(string) do
    string
    |> String.downcase()
    |> String.replace(" ", "_")
    |> String.replace(~r/[^a-z0-9-_]/, "-")
  end
end
