defmodule AshHqWeb.RedirectToHex do
  @moduledoc "Sets the platform being used with liveview"
  import Phoenix.LiveView
  require Ash.Query

  def on_mount(:default, %{"dsl_target" => dsl_target}, _session, socket) do
    to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

    AshHq.Docs.Module
    |> Ash.Query.filter(name == ^dsl_target or sanitized_name == ^dsl_target)
    |> Ash.Query.load(to_load)
    |> AshHq.Docs.read_one()
    |> case do
      {:ok, module} when not is_nil(module) ->
        {:halt, redirect(socket, external: AshHqWeb.DocRoutes.doc_link(module))}

      _ ->
        {:cont, socket}
    end
  end

  def on_mount(:default, %{"library" => library, "version" => version, "mix_task" => mix_task}, session, socket) do
    to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.MixTask)

    AshHq.Docs.MixTask
    |> Ash.Query.filter(name == ^mix_task or sanitized_name == ^mix_task)
    |> Ash.Query.load(to_load)
    |> AshHq.Docs.read_one()
    |> case do
      {:ok, module} when not is_nil(module) ->
        {:halt, redirect(socket, external: AshHqWeb.DocRoutes.doc_link(module))}

      _ ->
        on_mount(:default, %{"module" => mix_task, "library" => library, "version" => version}, session, socket)
    end
  end

  def on_mount(:default, %{"module" => module}, _session, socket) do
    to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

    AshHq.Docs.Module
    |> Ash.Query.filter(name == ^module or sanitized_name == ^module)
    |> Ash.Query.load(to_load)
    |> AshHq.Docs.read_one()
    |> case do
      {:ok, module} when not is_nil(module) ->
        {:halt, redirect(socket, external: AshHqWeb.DocRoutes.doc_link(module))}

      _ ->
        {:cont, socket}
    end
  end

  def on_mount(:default, %{"extension" => module}, _session, socket) do
    to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

    AshHq.Docs.Module
    |> Ash.Query.filter(name == ^module or sanitized_name == ^module)
    |> Ash.Query.load(to_load)
    |> AshHq.Docs.read_one()
    |> case do
      {:ok, module} when not is_nil(module) ->
        {:halt, redirect(socket, external: AshHqWeb.DocRoutes.doc_link(module))}

      _ ->
        {:cont, socket}
    end
  end



  def on_mount(:default, _params, _session, socket) do
    {:cont, socket}
  end
end
