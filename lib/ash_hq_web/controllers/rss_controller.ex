defmodule AshHqWeb.RssController do
  use AshHqWeb, :controller

  def rss(conn, _) do
    posts = AshHq.Blog.Post.published!()

    rss =
      posts
      |> AshBlog.rss_feed(
        title: "Ash Framework Blog",
        updated: &(&1.updated_at || &1.published_at),
        link: "https://ash-hq.org/blog",
        rss_link: "https://ash-hq.org/rss",
        html_body: & &1.body_html,
        linker: &"https://ash-hq.org/blog/#{&1.slug}",
        summary: & &1.tag_line,
        author: & &1.author
      )

    conn
    |> put_resp_content_type("application/atom+xml; charset=utf-8")
    |> send_resp(200, rss)
  end
end
