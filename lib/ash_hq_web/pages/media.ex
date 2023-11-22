defmodule AshHqWeb.Pages.Media do
  @moduledoc "Blog page"
  use Surface.LiveComponent

  def render(assigns) do
    ~F"""
    <div class="container sm:mx-auto">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-2 lg:col-span-1 flex-col flex space-y-4 items-center justify-center">
          <div class="text-3xl font-bold mt-8 mb-8 text-center">Podcasts</div>
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/us/podcast/episode-61-zach-daniel-and-the-ash-framework/id1550737059?i=1000630232631"
          />
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/us/podcast/creating-powerful-applications-using-ash-framework/id1379029137?i=1000590178245"
          />
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/us/podcast/123-ash-framework-models-resources/id1516100616?i=1000584632201"
          />
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/us/podcast/27-ash-framework-with-zach-daniel/id1516100616?i=1000503190100"
          />
        </div>
        <div class="col-span-2 lg:col-span-1 flex-col flex items-center">
          <div class="text-3xl font-bold mt-8 mb-8 text-center">Youtube Playlist</div>
          <iframe
            width="560"
            height="315"
            src="https://www.youtube-nocookie.com/embed/videoseries?list=PLZdi8gYWndC3gyOXale9BvCzMh6IunXyY"
            title="YouTube video player"
            frameborder="0"
            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
            allowfullscreen
          />
        </div>
      </div>

      <div class="text-2xl flex flex-col items-center justify-center text-center">
        <div class="text-3xl font-bold mt-8 mb-8 text-center">Example Projects</div>
        {#for %{title: title, href: href, description: description} <- examples()}
          <div class="max-w-7xl px-4 sm:px-6 md:px-8 my-8 hidden sm:block">
            <h2 class="mt-8 font-semibold text-red-500 dark:text-red-400">
              <a href={href}>{title}</a>
            </h2>
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
              {raw(description)}
            </p>
          </div>
        {/for}
      </div>
    </div>
    """
  end

  defp examples do
    [
      %{
        title: "AshHq",
        href: "https://github.com/ash-project/ash_hq",
        description: """
        This website that you're on right now!
        It contains all kinds of goodies, from a (now deprecated) ChatGPT bot, to a discord channel synchronizer, to a documentation importer.
        """
      },
      %{
        title: "Real World",
        href: "https://github.com/team-alembic/realworld",
        description: """
        An idiomatic Ash implementation of the <a href="https://codebase.show/projects/realworld">Real World example app</a>. Contains lots of idiomatic Ash code, and uses a demo application that is
        available in hundreds of languages/frameworks.
        """
      },
      %{
        title: "Todoish",
        href: "https://github.com/brettkolodny/todoish",
        description: """
        A bite sized Ash & LiveView application that lets you create and shate to-do lists.
        """
      }
    ]
  end
end
