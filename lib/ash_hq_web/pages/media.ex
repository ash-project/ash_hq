defmodule AshHqWeb.Pages.Media do
  @moduledoc "Blog page"
  use Surface.LiveComponent

  def render(assigns) do
    ~F"""
    <div class="container sm:mx-auto">
      <div class="grid grid-cols-2 gap-4">
        <div class="col-span-2 lg:col-span-1 flex-col">
          <div class="text-xl">Podcasts</div>
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            class="mb-4"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/us/podcast/creating-powerful-applications-using-ash-framework/id1379029137?i=1000590178245"
          />
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            class="mb-4"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/kr/podcast/123-ash-framework-models-resources/id1516100616?i=1000584632201"
          />
          <iframe
            allow="autoplay *; encrypted-media *; fullscreen *; clipboard-write"
            frameborder="0"
            height="175"
            style="width:100%;max-width:660px;overflow:hidden;background:transparent;"
            sandbox="allow-forms allow-popups allow-same-origin allow-scripts allow-storage-access-by-user-activation allow-top-navigation-by-user-activation"
            src="https://embed.podcasts.apple.com/ro/podcast/27-ash-framework-with-zach-daniel/id1516100616?i=1000503190100"
          />
        </div>
        <div class="col-span-2 lg:col-span-1">
          <div class="text-xl">Twitter</div>
          <a
            class="twitter-timeline"
            data-height="560px"
            href="https://twitter.com/AshFramework/lists/1604385682176327681?ref_src=twsrc%5Etfw"
          >Loading Twitter Feed...
          </a>
        </div>

        <div class="col-span-2 lg:col-span-1">
          <div class="text-xl">Youtube</div>
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

        <div class="col-span-2 lg:col-span-1 text-2xl">
          <div class="text-xl mb-8">Example Projects</div>
          <ul class="list-disc">
            <li class="mb-4">
              <a class="hover:text-primary-light-400 dark:hover:text-primary-dark-400" href="https://github.com/ash-project/ash_hq">AshHq (this website)</a>
            </li>
            <li class="mb-4">
              <a class="hover:text-primary-light-400 dark:hover:text-primary-dark-400" href="https://github.com/lukegalea/openats">Open ATS</a>
            </li>
            <li>
              <a class="hover:text-primary-light-400 dark:hover:text-primary-dark-400" href="https://github.com/brettkolodny/todoish">Todoish</a>
            </li>
          </ul>
        </div>
      </div>
    </div>
    """
  end
end
