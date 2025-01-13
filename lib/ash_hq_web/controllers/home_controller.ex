defmodule AshHqWeb.HomeController do
  use AshHqWeb, :controller

  @url_base if Mix.env() == :dev, do: "localhost:4000/new/", else: "https://new.ash-hq.org/"

  def home(conn, _) do
    conn
    |> assign(:url_base, @url_base)
    |> render("home.html")
  end
end
