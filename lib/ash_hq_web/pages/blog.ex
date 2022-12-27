defmodule AshHqWeb.Pages.Blog do
  @moduledoc "Blog page"
  use Surface.LiveComponent

  import AshHqWeb.Tails

  alias AshHqWeb.Components.Blog.Tag

  prop params, :map, default: %{}

  data post, :any, default: nil
  data posts, :any, default: []
  data tag, :string
  data tags, :any, default: []
  data slug, :string

  def render(assigns) do
    ~F"""
    <div class="container sm:mx-auto">
      <div class="flex flex-col sm:flex-row sm:pt-32 sm:mx-32 min-h-screen">
        <div class="sm:w-9/12">
          {#if @post}
            <head>
              <meta property="og:title" content={"Ash Framework Blog: #{@post.title}"}>
              <meta property="og:description" content={@post.tag_line}>
            </head>
            <div class="border shadow-sm rounded-lg px-8 pb-6 mb-6 dark:border-gray-600" ">
              <div class="border-b">
                <h1 class="mt-6 text-3xl font-semibold mb-4">{@post.title}</h1>
                <div class="flex flex-row space-x-2 mb-4">
                  {#for tag <- @post.tag_names}
                    <Tag tag={tag} />
                  {/for}
                </div>
                <div class="flex flex-row items-center align-middle justify-between">
                  <div>
                    {@post.author}
                  </div>
                  <div>
                    {@post.published_at |> DateTime.to_date()}
                  </div>
                </div>
              </div>
              <div class="prose prose-xl dark:prose-invert max-w-none mt-6">
                {raw(@post.body_html)}
              </div>
            </div>
          {#else}
            <head>
              <meta property="og:title" content="Ash Framework Blog">
              <meta
                property="og:description"
                content="A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
              />
            </head>
            {#if @tag}
              <h2 class="text-3xl font-semibold mb-1">Showing posts with tag: {@tag}</h2>
            {#else}
              <h2 class="text-3xl font-semibold mb-1">Showing all posts</h2>
            {/if}
            {#for post <- @posts}
              <div class="border shadow-sm rounded-lg px-8 pb-6 dark:border-gray-600 mb-4" ">
                <h1 class="mt-6 text-3xl font-semibold mb-4">{post.title}</h1>
                <div class="border-b pb-2">
                  <div>
                    {post.author}
                  </div>
                  <div>
                    {post.published_at |> DateTime.to_date()}
                  </div>
                  <div class="flex space-x-2">
                    {#for tag <- post.tag_names}
                      <Tag tag={tag} />
                    {/for}
                  </div>
                </div>
                <div class="flex flex-col sm:flex-row items-center mt-2 py-2">
                  <div class="text-muted pb-4 flex flex-grow">
                    {post.tag_line}
                  </div>
                  <a
                    href={"/blog/#{post.slug}"}
                    class="bg-primary-light-600 dark:bg-primary-dark-500 dark:text-black align-middle px-4 py-2 rounded-lg"
                  >
                    <div class="flex flex-row items-center">
                      <span>Read</span><Heroicons.Solid.ArrowRightIcon class="h-4 w-4" />
                    </div>
                  </a>
                </div>
              </div>
            {/for}
          {/if}
        </div>
        <div class={classes(["flex flex-col px-4 sm:pr-0 sm:pl-4 sm:w-3/12 space-y-6", "mt-9": !@post])}>
          <div class="border rounded-lg p-4 flex flex-col w-full dark:border-gray-600">
            <h3 class="text-lg font-bold mb-1">All Tags:</h3>
            <div class="flex gap-2 flex-wrap w-full">
              {#for tag <- @tags}
                <Tag tag={to_string(tag.name)} />
              {/for}
            </div>
          </div>
          <div class="border rounded-lg p-4 flex flex-col w-full dark:border-gray-600">
            <h3 class="text-lg font-bold mb-1">Connect</h3>
            <div class="flex flex-wrap gap-4">
              <a href="/rss" title="RSS Feed">
                <Heroicons.Solid.RssIcon class="w-6 h-6 dark:fill-base-dark-400 dark:hover:fill-base-dark-200 hover:fill-base-light-600" />
              </a>
              <a href="https://github.com/ash-project" title="Github">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="w-6 h-6 dark:fill-base-dark-400 dark:hover:fill-base-dark-200 hover:fill-base-light-600"
                  viewBox="0 0 24 24"
                ><path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" /></svg>
              </a>
              <a href="https://discord.gg/D7FNG2q" title="Discord">
                <svg
                  class="w-6 h-6 fill-black dark:fill-base-dark-400 dark:hover:fill-base-dark-200 hover:fill-base-light-600"
                  viewBox="0 0 71 55"
                  fill="none"
                  xmlns="http://www.w3.org/2000/svg"
                >
                  <g clip-path="url(#clip0)">
                    <path d="M60.1045 4.8978C55.5792 2.8214 50.7265 1.2916 45.6527 0.41542C45.5603 0.39851 45.468 0.440769 45.4204 0.525289C44.7963 1.6353 44.105 3.0834 43.6209 4.2216C38.1637 3.4046 32.7345 3.4046 27.3892 4.2216C26.905 3.0581 26.1886 1.6353 25.5617 0.525289C25.5141 0.443589 25.4218 0.40133 25.3294 0.41542C20.2584 1.2888 15.4057 2.8186 10.8776 4.8978C10.8384 4.9147 10.8048 4.9429 10.7825 4.9795C1.57795 18.7309 -0.943561 32.1443 0.293408 45.3914C0.299005 45.4562 0.335386 45.5182 0.385761 45.5576C6.45866 50.0174 12.3413 52.7249 18.1147 54.5195C18.2071 54.5477 18.305 54.5139 18.3638 54.4378C19.7295 52.5728 20.9469 50.6063 21.9907 48.5383C22.0523 48.4172 21.9935 48.2735 21.8676 48.2256C19.9366 47.4931 18.0979 46.6 16.3292 45.5858C16.1893 45.5041 16.1781 45.304 16.3068 45.2082C16.679 44.9293 17.0513 44.6391 17.4067 44.3461C17.471 44.2926 17.5606 44.2813 17.6362 44.3151C29.2558 49.6202 41.8354 49.6202 53.3179 44.3151C53.3935 44.2785 53.4831 44.2898 53.5502 44.3433C53.9057 44.6363 54.2779 44.9293 54.6529 45.2082C54.7816 45.304 54.7732 45.5041 54.6333 45.5858C52.8646 46.6197 51.0259 47.4931 49.0921 48.2228C48.9662 48.2707 48.9102 48.4172 48.9718 48.5383C50.038 50.6034 51.2554 52.5699 52.5959 54.435C52.6519 54.5139 52.7526 54.5477 52.845 54.5195C58.6464 52.7249 64.529 50.0174 70.6019 45.5576C70.6551 45.5182 70.6887 45.459 70.6943 45.3942C72.1747 30.0791 68.2147 16.7757 60.1968 4.9823C60.1772 4.9429 60.1437 4.9147 60.1045 4.8978ZM23.7259 37.3253C20.2276 37.3253 17.3451 34.1136 17.3451 30.1693C17.3451 26.225 20.1717 23.0133 23.7259 23.0133C27.308 23.0133 30.1626 26.2532 30.1066 30.1693C30.1066 34.1136 27.28 37.3253 23.7259 37.3253ZM47.3178 37.3253C43.8196 37.3253 40.9371 34.1136 40.9371 30.1693C40.9371 26.225 43.7636 23.0133 47.3178 23.0133C50.9 23.0133 53.7545 26.2532 53.6986 30.1693C53.6986 34.1136 50.9 37.3253 47.3178 37.3253Z" />
                  </g>
                  <defs>
                    <clipPath id="clip0">
                      <rect width="71" height="55" fill="white" />
                    </clipPath>
                  </defs>
                </svg>
              </a>
              <a href="https://twitter.com/ashframework" title="Twitter">
                <svg
                  class="w-6 h-6 dark:fill-base-dark-400 dark:hover:fill-base-dark-200 hover:fill-base-light-600"
                  version="1.1"
                  viewBox="0 0 248 204"
                  style="enable-background:new 0 0 248 204;"
                >
                  <g id="Logo_1_">
                    <path d="M221.95,51.29c0.15,2.17,0.15,4.34,0.15,6.53c0,66.73-50.8,143.69-143.69,143.69v-0.04
        C50.97,201.51,24.1,193.65,1,178.83c3.99,0.48,8,0.72,12.02,0.73c22.74,0.02,44.83-7.61,62.72-21.66
        c-21.61-0.41-40.56-14.5-47.18-35.07c7.57,1.46,15.37,1.16,22.8-0.87C27.8,117.2,10.85,96.5,10.85,72.46c0-0.22,0-0.43,0-0.64
        c7.02,3.91,14.88,6.08,22.92,6.32C11.58,63.31,4.74,33.79,18.14,10.71c25.64,31.55,63.47,50.73,104.08,52.76
        c-4.07-17.54,1.49-35.92,14.61-48.25c20.34-19.12,52.33-18.14,71.45,2.19c11.31-2.23,22.15-6.38,32.07-12.26
        c-3.77,11.69-11.66,21.62-22.2,27.93c10.01-1.18,19.79-3.86,29-7.95C240.37,35.29,231.83,44.14,221.95,51.29z" />
                  </g>
                </svg>
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_tags()
     |> assign_filters()
     |> assign_post()
     |> assign_posts()}
  end

  defp assign_post(socket) do
    if socket.assigns.params["slug"] do
      assign(socket, :post, AshHq.Blog.Post.by_slug!(socket.assigns.params["slug"]))
    else
      assign(socket, :post, nil)
    end
  end

  defp assign_posts(socket) do
    assign(socket, :posts, AshHq.Blog.Post.published!(%{tag: socket.assigns.tag}))
  end

  defp assign_filters(socket) do
    socket
    |> assign(:tag, socket.assigns.params["tag"])
    |> assign(:slug, socket.assigns.params["slug"])
  end

  defp assign_tags(socket) do
    socket
    |> assign(:tags, AshHq.Blog.Tag.read!())
  end
end
