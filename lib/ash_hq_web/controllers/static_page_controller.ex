defmodule AshHqWeb.StaticPageController do
  @moduledoc """
  Pages that are static sites of their own, in `priv/static`: slides from talks, in
  `talks/<talk>`, and articles too interactive for the blog's markdown, in
  `articles/<article>`.

  Their files are served as static files, apart from each page itself, which is served
  here so it can live at a URL of its own. An article lives at the URL of its blog post.
  """
  use AshHqWeb, :controller

  @talks ~w(time-travel-for-normies)
  @articles %{"introducing-temporal-resources" => "temporal-resources"}

  def talk(conn, %{"talk" => talk}) when talk in @talks do
    send_page(conn, "talks/#{talk}")
  end

  def talk(conn, _params), do: send_resp(conn, 404, "Not found")

  def article(conn, _params) do
    [_, slug] = conn.path_info
    send_page(conn, "articles/#{Map.fetch!(@articles, slug)}")
  end

  defp send_page(conn, path) do
    conn
    |> put_resp_content_type("text/html")
    |> send_file(200, Application.app_dir(:ash_hq, "priv/static/#{path}/index.html"))
  end
end
