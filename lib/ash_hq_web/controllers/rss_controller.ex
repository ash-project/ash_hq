defmodule AshHqWeb.RssController do
  use AshHqWeb, :controller

  def rss(conn, _) do
    rss =
      AshHq.Blog.Post.published!()
      |> AshBlog.rss_feed(
        html_body: & &1.body_html,
        link: &"blog/#{&1.slug}",
        summary: & &1.tag_line,
        author: & &1.author
      )

    conn
    |> put_resp_content_type("application/atom+xml; charset=utf-8")
    |> send_resp(200, rss)
  end
end
