defmodule AshHqWeb.SessionPlug do
  @moduledoc false
  @behaviour Plug

  @cookies_to_replicate [
    "theme",
    "selected_versions",
    "selected_types",
    "christmas"
  ]

  def init(_), do: []

  def call(conn, _) do
    Enum.reduce(@cookies_to_replicate, conn, fn cookie, conn ->
      case conn.req_cookies[cookie] do
        value when value in [nil, "", "null"] ->
          Plug.Conn.put_session(conn, cookie, nil)

        value ->
          Plug.Conn.put_session(conn, cookie, value)
      end
    end)
    |> Plug.Conn.assign(:configured_theme, conn.assigns[:configured_theme] || "dark")
  end
end
