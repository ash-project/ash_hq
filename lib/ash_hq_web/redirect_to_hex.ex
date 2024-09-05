defmodule AshHqWeb.RedirectToHex do
  @moduledoc "Sets the platform being used with liveview"
  import Phoenix.LiveView
  require Ash.Query
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    case conn.params do
      %{"dsl_target" => dsl_target} ->
        to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

        AshHq.Docs.Module
        |> Ash.Query.filter(name == ^dsl_target or sanitized_name == ^dsl_target)
        |> Ash.Query.load(to_load)
        |> Ash.read_one()
        |> case do
          {:ok, module} when not is_nil(module) ->
            redirect_to_hex(conn, AshHqWeb.DocRoutes.doc_link(module))

          _ ->
            Phoenix.Controller.redirect(conn, to: "/")
        end

      %{"mix_task" => mix_task} ->
        to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.MixTask)

        AshHq.Docs.MixTask
        |> Ash.Query.filter(name == ^mix_task or sanitized_name == ^mix_task)
        |> Ash.Query.load(to_load)
        |> Ash.read_one()
        |> case do
          {:ok, module} when not is_nil(module) ->
            redirect_to_hex(conn, AshHqWeb.DocRoutes.doc_link(module))

          _ ->
            to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

            AshHq.Docs.Module
            |> Ash.Query.filter(name == ^mix_task or sanitized_name == ^mix_task)
            |> Ash.Query.load(to_load)
            |> Ash.read_one()
            |> case do
              {:ok, module} when not is_nil(module) ->
                redirect_to_hex(conn, AshHqWeb.DocRoutes.doc_link(module))

              _ ->
                Phoenix.Controller.redirect(conn, to: "/")
            end
        end

      %{"module" => module} ->
        to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

        AshHq.Docs.Module
        |> Ash.Query.filter(name == ^module or sanitized_name == ^module)
        |> Ash.Query.load(to_load)
        |> Ash.read_one()
        |> case do
          {:ok, module} when not is_nil(module) ->
            redirect_to_hex(conn, AshHqWeb.DocRoutes.doc_link(module))

          _ ->
            Phoenix.Controller.redirect(conn, to: "/")
        end

      %{"extension" => module} ->
        to_load = AshHq.Docs.Extensions.Search.load_for_search(AshHq.Docs.Module)

        AshHq.Docs.Module
        |> Ash.Query.filter(name == ^module or sanitized_name == ^module)
        |> Ash.Query.load(to_load)
        |> Ash.read_one()
        |> case do
          {:ok, module} when not is_nil(module) ->
            redirect_to_hex(conn, AshHqWeb.DocRoutes.doc_link(module))

          _ ->
            Phoenix.Controller.redirect(conn, to: "/")
        end

      %{"guide" => path, "library" => library} ->
        redirect_to_hex(conn, "https://hexdocs.pm/#{library}/#{List.last(path)}.html")

      _ ->
        conn
    end
  end

  defp redirect_to_hex(conn, to) do
    conn
    |> Plug.Conn.put_status(302)
    |> Phoenix.Controller.redirect(external: to)
    |> Plug.Conn.halt()
  end
end
