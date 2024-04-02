defmodule AshHqWeb.Pages.Community do
  @moduledoc "The Community page - a spot to collect the various links to different Ash community hubs that exist around the web."

  use Phoenix.Component

  alias AshHqWeb.Components.{CalloutText, CommunityLink}

  def community(assigns) do
    ~H"""
    <div class="container sm:mx-auto">
      <div class="flex flex-col w-full sm:flex-row sm:pt-12 sm:mx-32 min-h-screen">
        <div class="sm:w-9/12">
          <head>
            <meta property="og:title" content="Ash Framework Blog">
            <meta
              property="og:description"
              content="A declarative foundation for ambitious Elixir applications. Model your domain, derive the rest."
            />
          </head>

          <div class="px-4 md:px-12 max-w-5xl mx-auto mt-8 flex justify-center">
            <img class="h-32 md:h-64" src="/images/ash-logo-cropped.svg">
          </div>
          <div class="text-3xl md:text-5xl px-4 md:px-12 font-bold max-w-5xl mx-auto mt-8 text-center">
            Join the <CalloutText.callout text="Community" />
          </div>
          <div class="text-2xl font-light text-base-dark-700 dark:text-base-light-100 max-w-4xl mx-auto px-4 md:px-0 mt-4 text-center">
            The Ash Framework has a thriving community ready to welcome developers at all skill levels. All questions, ideas and contributions are valuable, so please join in!
          </div>
          <div class="grid justify-center grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 dark:bg-none dark:bg-opacity-0 py-6 text-center mx-8 gap-16  mt-2 border-t border-t-gray-600 pt-16">
            <CommunityLink.link name="Discord" url="https://discord.gg/FmeMvFrw3j">
              <:description>
                The Ash discord is where you'll find people sharing ideas, collaborating on code, and discussing the Elixir ecosystem.
              </:description>
              <:icon>
                <svg width="71" height="55" viewBox="0 0 71 55" fill="#5865F2" xmlns="http://www.w3.org/2000/svg">
                  <g clip-path="url(#clip0)">
                    <path d="M60.1045 4.8978C55.5792 2.8214 50.7265 1.2916 45.6527 0.41542C45.5603 0.39851 45.468 0.440769 45.4204 0.525289C44.7963 1.6353 44.105 3.0834 43.6209 4.2216C38.1637 3.4046 32.7345 3.4046 27.3892 4.2216C26.905 3.0581 26.1886 1.6353 25.5617 0.525289C25.5141 0.443589 25.4218 0.40133 25.3294 0.41542C20.2584 1.2888 15.4057 2.8186 10.8776 4.8978C10.8384 4.9147 10.8048 4.9429 10.7825 4.9795C1.57795 18.7309 -0.943561 32.1443 0.293408 45.3914C0.299005 45.4562 0.335386 45.5182 0.385761 45.5576C6.45866 50.0174 12.3413 52.7249 18.1147 54.5195C18.2071 54.5477 18.305 54.5139 18.3638 54.4378C19.7295 52.5728 20.9469 50.6063 21.9907 48.5383C22.0523 48.4172 21.9935 48.2735 21.8676 48.2256C19.9366 47.4931 18.0979 46.6 16.3292 45.5858C16.1893 45.5041 16.1781 45.304 16.3068 45.2082C16.679 44.9293 17.0513 44.6391 17.4067 44.3461C17.471 44.2926 17.5606 44.2813 17.6362 44.3151C29.2558 49.6202 41.8354 49.6202 53.3179 44.3151C53.3935 44.2785 53.4831 44.2898 53.5502 44.3433C53.9057 44.6363 54.2779 44.9293 54.6529 45.2082C54.7816 45.304 54.7732 45.5041 54.6333 45.5858C52.8646 46.6197 51.0259 47.4931 49.0921 48.2228C48.9662 48.2707 48.9102 48.4172 48.9718 48.5383C50.038 50.6034 51.2554 52.5699 52.5959 54.435C52.6519 54.5139 52.7526 54.5477 52.845 54.5195C58.6464 52.7249 64.529 50.0174 70.6019 45.5576C70.6551 45.5182 70.6887 45.459 70.6943 45.3942C72.1747 30.0791 68.2147 16.7757 60.1968 4.9823C60.1772 4.9429 60.1437 4.9147 60.1045 4.8978ZM23.7259 37.3253C20.2276 37.3253 17.3451 34.1136 17.3451 30.1693C17.3451 26.225 20.1717 23.0133 23.7259 23.0133C27.308 23.0133 30.1626 26.2532 30.1066 30.1693C30.1066 34.1136 27.28 37.3253 23.7259 37.3253ZM47.3178 37.3253C43.8196 37.3253 40.9371 34.1136 40.9371 30.1693C40.9371 26.225 43.7636 23.0133 47.3178 23.0133C50.9 23.0133 53.7545 26.2532 53.6986 30.1693C53.6986 34.1136 50.9 37.3253 47.3178 37.3253Z" />
                  </g>
                  <defs>
                    <clipPath id="clip0">
                      <rect width="71" height="55" fill="white" />
                    </clipPath>
                  </defs>
                </svg>
              </:icon>
            </CommunityLink.link>
            <CommunityLink.link
              name="Elixir Forum"
              url="https://elixirforum.com/c/elixir-framework-forums/ash-framework-forum/123"
            >
              <:description>
                The Ash section on Elixir Forum is the perfect place to ask questions or see what other people have been building.
              </:description>
              <:icon>
                <svg fill="#CF3DFE" viewBox="0 0 24 24" role="img" xmlns="http://www.w3.org/2000/svg"><path d="M19.793 16.575c0 3.752-2.927 7.426-7.743 7.426-5.249 0-7.843-3.71-7.843-8.29 0-5.21 3.892-12.952 8-15.647a.397.397 0 0 1 .61.371 9.716 9.716 0 0 0 1.694 6.518c.522.795 1.092 1.478 1.763 2.352.94 1.227 1.637 1.906 2.644 3.842l.015.028a7.107 7.107 0 0 1 .86 3.4z" /></svg>
              </:icon>
            </CommunityLink.link>
            <CommunityLink.link name="GitHub" url="https://github.com/ash-project">
              <:description>
                The Ash Project on GitHub is your one stop shop for all of the source code across the various Ash libraries.
              </:description>
              <:icon>
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  x="0px"
                  y="0px"
                  width="80"
                  height="80"
                  viewBox="0,0,256,256"
                >
                  <g transform="translate(-51.2,-51.2) scale(1.4,1.4)"><g
                      fill="#2DBA4E"
                      fill-rule="nonzero"
                      stroke="none"
                      stroke-width="1"
                      stroke-linecap="butt"
                      stroke-linejoin="miter"
                      stroke-miterlimit="10"
                      stroke-dasharray=""
                      stroke-dashoffset="0"
                      font-family="none"
                      font-weight="none"
                      font-size="none"
                      text-anchor="none"
                      style="mix-blend-mode: normal"
                    ><g transform="scale(3.55556,3.55556)"><path d="M36,12c13.255,0 24,10.745 24,24c0,10.656 -6.948,19.685 -16.559,22.818c0.003,-0.009 0.007,-0.022 0.007,-0.022c0,0 -1.62,-0.759 -1.586,-2.114c0.038,-1.491 0,-4.971 0,-6.248c0,-2.193 -1.388,-3.747 -1.388,-3.747c0,0 10.884,0.122 10.884,-11.491c0,-4.481 -2.342,-6.812 -2.342,-6.812c0,0 1.23,-4.784 -0.426,-6.812c-1.856,-0.2 -5.18,1.774 -6.6,2.697c0,0 -2.25,-0.922 -5.991,-0.922c-3.742,0 -5.991,0.922 -5.991,0.922c-1.419,-0.922 -4.744,-2.897 -6.6,-2.697c-1.656,2.029 -0.426,6.812 -0.426,6.812c0,0 -2.342,2.332 -2.342,6.812c0,11.613 10.884,11.491 10.884,11.491c0,0 -1.097,1.239 -1.336,3.061c-0.76,0.258 -1.877,0.576 -2.78,0.576c-2.362,0 -4.159,-2.296 -4.817,-3.358c-0.649,-1.048 -1.98,-1.927 -3.221,-1.927c-0.817,0 -1.216,0.409 -1.216,0.876c0,0.467 1.146,0.793 1.902,1.659c1.594,1.826 1.565,5.933 7.245,5.933c0.617,0 1.876,-0.152 2.823,-0.279c-0.006,1.293 -0.007,2.657 0.013,3.454c0.034,1.355 -1.586,2.114 -1.586,2.114c0,0 0.004,0.013 0.007,0.022c-9.61,-3.133 -16.558,-12.162 -16.558,-22.818c0,-13.255 10.745,-24 24,-24z" /></g></g></g>
                </svg>
              </:icon>
            </CommunityLink.link>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
