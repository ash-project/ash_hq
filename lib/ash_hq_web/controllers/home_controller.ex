defmodule AshHqWeb.HomeController do
  use AshHqWeb, :controller

  def home(conn, _) do
    conn
    |> render("home.html")
  end
end
