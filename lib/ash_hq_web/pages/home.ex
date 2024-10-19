defmodule AshHqWeb.Pages.Home do
  @moduledoc "The home page"

  use Phoenix.LiveComponent

  alias AshHqWeb.Components.{CalloutText, CodeExample, Feature}
  import AshHqWeb.Components.CodeExample, only: [to_code: 1]

  def render(assigns) do
    ~H"""
    <div class="antialiased">
      <div class="my-2 mx-2 dark:bg-base-dark-850 flex flex-col items-center pt-4 md:pt-12">
        <div class="flex flex-col">
          <img class="h-64" src="/images/ash-logo-side.svg">
        </div>
        <div class="text-3xl md:text-5xl px-4 md:px-12 font-bold max-w-5xl mx-auto mt-8 md:text-center">
          Model your domain, <CalloutText.callout text="derive the rest" />
        </div>
        <div class="text-2xl font-light text-base-dark-700 dark:text-base-light-100 max-w-4xl mx-auto px-4 md:px-0 mt-4 md:text-center">
          Build <CalloutText.callout text="powerful Elixir applications" /> with a <CalloutText.callout text="flexible" /> toolchain.
        </div>

        <div class="flex flex-col space-y-4 md:space-x-4 md:space-y-0 md:flex-row items-center mt-8 mb-6 md:mb-10">
          <a
            href="https://hexdocs.pm/ash/readme.html"
            class="flex justify-center items-center w-full md:w-auto h-12 px-4 rounded-lg bg-primary-light-500 dark:bg-primary-dark-500 font-semibold dark:text-white dark:hover:bg-primary-dark-700 hover:bg-primary-light-700"
          >
            Get Started
          </a>
          <div class="flex flex-col space-y-4 md:space-x-4 md:space-y-0 md:flex-row items-center rounded-lg mt-8 mb-6 md:mb-10 border border-primary-light-500 hover:bg-primary-light-500 dark:hover:bg-primary-dark-500 dark:border-primary-dark-500">
            <a
              href="https://alembic.com.au/contact"
              class="flex justify-center items-center w-full md:w-auto h-12 px-4 rounded-lg font-semibold dark:text-white"
            >
              Talk to an expert
            </a>
          </div>
        </div>

        <div class="mb-4 md:mb-8 hidden sm:block">
          <span class="flex items-center justify-center h-full bg-base-light-100 dark:bg-base-dark-800 rounded-full overflow-hidden text-center font-bold p-4">OR</span>
        </div>

        <div class="hidden sm:flex justify-center items-center gap-4">
          <a
            href="https://livebook.dev/run?url=https%3A%2F%2Fgithub.com%2Fash-project%2Fash_tutorial%2Fblob%2Fmaster%2Foverview.livemd"
            class="hover:scale-110 transition"
          >
            <img src="https://livebook.dev/badge/v1/pink.svg" alt="Run in Livebook">
          </a>
          <div class="flex">
            <svg
              width="100"
              xmlns="http://www.w3.org/2000/svg"
              version="1.1"
              xmlns:xlink="http://www.w3.org/1999/xlink"
              xmlns:svgjs="http://svgjs.dev/svgjs"
              viewBox="50 300 650 200"
            ><g
                stroke-width="11"
                stroke="hsl(0, 0%, 75%)"
                fill="none"
                stroke-linecap="round"
                stroke-linejoin="round"
                stroke-dasharray="19 30"
                transform="matrix(-0.6293203910498373,0.777145961456971,-0.777145961456971,-0.6293203910498373,938.5865410027234,330.8697718371465)"
              ><path
                  d="M188.5 188.5Q415.5 590.5 400 400Q392.5 157.5 611.5 611.5"
                  marker-end="url(#SvgjsMarker5399)"
                /></g><defs><marker
                  markerWidth="5"
                  markerHeight="5"
                  refX="2.5"
                  refY="2.5"
                  viewBox="0 0 5 5"
                  orient="auto"
                  id="SvgjsMarker5399"
                ><polygon points="0,5 1.6666666666666667,2.5 0,0 5,2.5" fill="hsl(0, 0%, 75%)" /></marker></defs></svg>
            <p class="italic text-sm max-w-[100px] text-center">Try our interactive tutorial with Livebook</p>
          </div>
        </div>

        <div class="grid justify-center grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 dark:bg-none dark:bg-opacity-0 py-6 text-center mx-8 gap-16 max-w-lg md:max-w-lg xl:max-w-4xl mt-2 pt-16">
          <Feature.feature name="Resources">
            <:description>
              <CalloutText.callout text="Plug and play" /> building blocks that scale with the complexity of your application.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M9 4.5a.75.75 0 01.721.544l.813 2.846a3.75 3.75 0 002.576 2.576l2.846.813a.75.75 0 010 1.442l-2.846.813a3.75 3.75 0 00-2.576 2.576l-.813 2.846a.75.75 0 01-1.442 0l-.813-2.846a3.75 3.75 0 00-2.576-2.576l-2.846-.813a.75.75 0 010-1.442l2.846-.813A3.75 3.75 0 007.466 7.89l.813-2.846A.75.75 0 019 4.5zM18 1.5a.75.75 0 01.728.568l.258 1.036c.236.94.97 1.674 1.91 1.91l1.036.258a.75.75 0 010 1.456l-1.036.258c-.94.236-1.674.97-1.91 1.91l-.258 1.036a.75.75 0 01-1.456 0l-.258-1.036a2.625 2.625 0 00-1.91-1.91l-1.036-.258a.75.75 0 010-1.456l1.036-.258a2.625 2.625 0 001.91-1.91l.258-1.036A.75.75 0 0118 1.5zM16.5 15a.75.75 0 01.712.513l.394 1.183c.15.447.5.799.948.948l1.183.395a.75.75 0 010 1.422l-1.183.395c-.447.15-.799.5-.948.948l-.395 1.183a.75.75 0 01-1.422 0l-.395-1.183a1.5 1.5 0 00-.948-.948l-1.183-.395a.75.75 0 010-1.422l1.183-.395c.447-.15.799-.5.948-.948l.395-1.183A.75.75 0 0116.5 15z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="GraphQL" class="text-pink-700 dark:text-pink-500">
            <:description>
              Easily create rich, customizable, full featured <CalloutText.callout text="GraphQL APIs" /> backed by Absinthe.
            </:description>
            <:icon>
              <svg role="img" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><title /><path d="M14.051 2.751l4.935 2.85c.816-.859 2.173-.893 3.032-.077.148.14.274.301.377.477.589 1.028.232 2.339-.796 2.928-.174.1-.361.175-.558.223v5.699c1.146.273 1.854 1.423 1.58 2.569-.048.204-.127.4-.232.581-.592 1.023-1.901 1.374-2.927.782-.196-.113-.375-.259-.526-.429l-4.905 2.832c.372 1.124-.238 2.335-1.361 2.706-.217.071-.442.108-.67.108-1.181.001-2.139-.955-2.14-2.136 0-.205.029-.41.088-.609l-4.936-2.847c-.816.854-2.171.887-3.026.07-.854-.816-.886-2.171-.07-3.026.283-.297.646-.506 1.044-.603l.001-5.699c-1.15-.276-1.858-1.433-1.581-2.584.047-.198.123-.389.224-.566.592-1.024 1.902-1.374 2.927-.782.177.101.339.228.48.377l4.938-2.85C9.613 1.612 10.26.423 11.39.088 11.587.029 11.794 0 12 0c1.181-.001 2.139.954 2.14 2.134.001.209-.03.418-.089.617zm-.515.877c-.019.021-.037.039-.058.058l6.461 11.19c.026-.009.056-.016.082-.023V9.146c-1.145-.283-1.842-1.442-1.558-2.588.006-.024.012-.049.019-.072l-4.946-2.858zm-3.015.059l-.06-.06-4.946 2.852c.327 1.135-.327 2.318-1.461 2.645-.026.008-.051.014-.076.021v5.708l.084.023 6.461-11.19-.002.001zm2.076.507c-.39.112-.803.112-1.192 0l-6.46 11.189c.294.283.502.645.6 1.041h12.911c.097-.398.307-.761.603-1.044L12.597 4.194zm.986 16.227l4.913-2.838c-.015-.047-.027-.094-.038-.142H5.542l-.021.083 4.939 2.852c.388-.404.934-.653 1.54-.653.627 0 1.19.269 1.583.698z" /></svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="JSON:API" class="text-green-700 dark:text-green-600">
            <:description>
              Create JSON:API spec compliant apis in <CalloutText.callout text="minutes," /> not days.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 32 32" version="1.1">
                <title>alt-curly</title>
                <path d="M0 16q0 1.664 1.184 2.848t2.816 1.152q0.832 0 1.408 0.608t0.608 1.408v4q0 2.496 1.728 4.224t4.256 1.76v-4q-0.832 0-1.408-0.576t-0.576-1.408v-4q0-2.496-1.76-4.256t-4.256-1.76q2.496 0 4.256-1.76t1.76-4.224v-4q0-0.864 0.576-1.44t1.408-0.576v-4q-2.496 0-4.256 1.76t-1.728 4.256v4q0 0.832-0.608 1.408t-1.408 0.576q-1.664 0-2.816 1.184t-1.184 2.816zM14.016 16q0 0.832 0.576 1.44t1.408 0.576 1.408-0.576 0.608-1.44-0.608-1.408-1.408-0.576-1.408 0.576-0.576 1.408zM20 28v4q2.496 0 4.256-1.76t1.76-4.224v-4q0-0.864 0.576-1.44t1.408-0.576q1.664 0 2.816-1.152t1.184-2.848-1.184-2.816-2.816-1.184q-0.832 0-1.408-0.576t-0.576-1.408v-4q0-2.496-1.76-4.256t-4.256-1.76v4q0.832 0 1.408 0.608t0.608 1.408v4q0 2.496 1.728 4.224t4.256 1.76q-2.496 0-4.256 1.76t-1.728 4.256v4q0 0.832-0.608 1.408t-1.408 0.576z" />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Authentication" class="text-indigo-500 dark:text-indigo-400">
            <:description>
              Effortless authentication with <CalloutText.callout text="magic link" /> and <CalloutText.callout text="social login" /> out of the box.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M18.685 19.097A9.723 9.723 0 0021.75 12c0-5.385-4.365-9.75-9.75-9.75S2.25 6.615 2.25 12a9.723 9.723 0 003.065 7.097A9.716 9.716 0 0012 21.75a9.716 9.716 0 006.685-2.653zm-12.54-1.285A7.486 7.486 0 0112 15a7.486 7.486 0 015.855 2.812A8.224 8.224 0 0112 20.25a8.224 8.224 0 01-5.855-2.438zM15.75 9a3.75 3.75 0 11-7.5 0 3.75 3.75 0 017.5 0z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Community" class="text-red-700 dark:text-red-500">
            <:description>
              A thriving community of people <CalloutText.callout text="working together" /> to <CalloutText.callout text="build and learn." />
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M11.645 20.91l-.007-.003-.022-.012a15.247 15.247 0 01-.383-.218 25.18 25.18 0 01-4.244-3.17C4.688 15.36 2.25 12.174 2.25 8.25 2.25 5.322 4.714 3 7.688 3A5.5 5.5 0 0112 5.052 5.5 5.5 0 0116.313 3c2.973 0 5.437 2.322 5.437 5.25 0 3.925-2.438 7.111-4.739 9.256a25.175 25.175 0 01-4.244 3.17 15.247 15.247 0 01-.383.219l-.022.012-.007.004-.003.001a.752.752 0 01-.704 0l-.003-.001z" />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Authorization" class="text-gray-700 dark:text-gray-400">
            <:description>
              Add row and field level policies to <CalloutText.callout text="prohibit access" /> to data.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M12 1.5a5.25 5.25 0 00-5.25 5.25v3a3 3 0 00-3 3v6.75a3 3 0 003 3h10.5a3 3 0 003-3v-6.75a3 3 0 00-3-3v-3c0-2.9-2.35-5.25-5.25-5.25zm3.75 8.25v-3a3.75 3.75 0 10-7.5 0v3h7.5z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Multitenancy" class="text-black dark:text-white">
            <:description>
              <CalloutText.callout text="Built in strategies" /> for splitting your application by tenant.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M3 2.25a.75.75 0 000 1.5v16.5h-.75a.75.75 0 000 1.5H15v-18a.75.75 0 000-1.5H3zM6.75 19.5v-2.25a.75.75 0 01.75-.75h3a.75.75 0 01.75.75v2.25a.75.75 0 01-.75.75h-3a.75.75 0 01-.75-.75zM6 6.75A.75.75 0 016.75 6h.75a.75.75 0 010 1.5h-.75A.75.75 0 016 6.75zM6.75 9a.75.75 0 000 1.5h.75a.75.75 0 000-1.5h-.75zM6 12.75a.75.75 0 01.75-.75h.75a.75.75 0 010 1.5h-.75a.75.75 0 01-.75-.75zM10.5 6a.75.75 0 000 1.5h.75a.75.75 0 000-1.5h-.75zm-.75 3.75A.75.75 0 0110.5 9h.75a.75.75 0 010 1.5h-.75a.75.75 0 01-.75-.75zM10.5 12a.75.75 0 000 1.5h.75a.75.75 0 000-1.5h-.75zM16.5 6.75v15h5.25a.75.75 0 000-1.5H21v-12a.75.75 0 000-1.5h-4.5zm1.5 4.5a.75.75 0 01.75-.75h.008a.75.75 0 01.75.75v.008a.75.75 0 01-.75.75h-.008a.75.75 0 01-.75-.75v-.008zm.75 2.25a.75.75 0 00-.75.75v.008c0 .414.336.75.75.75h.008a.75.75 0 00.75-.75v-.008a.75.75 0 00-.75-.75h-.008zM18 17.25a.75.75 0 01.75-.75h.008a.75.75 0 01.75.75v.008a.75.75 0 01-.75.75h-.008a.75.75 0 01-.75-.75v-.008z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Data Layers" class="text-yellow-800 dark:text-yellow-500">
            <:description>
              Postgres, Ets, Mnesia, CSV and <CalloutText.callout text="more on the way!" />
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M21 6.375c0 2.692-4.03 4.875-9 4.875S3 9.067 3 6.375 7.03 1.5 12 1.5s9 2.183 9 4.875z" />
                <path d="M12 12.75c2.685 0 5.19-.586 7.078-1.609a8.283 8.283 0 001.897-1.384c.016.121.025.244.025.368C21 12.817 16.97 15 12 15s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.285 8.285 0 001.897 1.384C6.809 12.164 9.315 12.75 12 12.75z" />
                <path d="M12 16.5c2.685 0 5.19-.586 7.078-1.609a8.282 8.282 0 001.897-1.384c.016.121.025.244.025.368 0 2.692-4.03 4.875-9 4.875s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.284 8.284 0 001.897 1.384C6.809 15.914 9.315 16.5 12 16.5z" />
                <path d="M12 20.25c2.685 0 5.19-.586 7.078-1.609a8.282 8.282 0 001.897-1.384c.016.121.025.244.025.368 0 2.692-4.03 4.875-9 4.875s-9-2.183-9-4.875c0-.124.009-.247.025-.368a8.284 8.284 0 001.897 1.384C6.809 19.664 9.315 20.25 12 20.25z" />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Admin" class="text-violet-700 dark:text-violet-400">
            <:description>
              A <CalloutText.callout text="push-button admin interface" /> you can drop right into your application.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path d="M18.75 12.75h1.5a.75.75 0 000-1.5h-1.5a.75.75 0 000 1.5zM12 6a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5A.75.75 0 0112 6zM12 18a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5A.75.75 0 0112 18zM3.75 6.75h1.5a.75.75 0 100-1.5h-1.5a.75.75 0 000 1.5zM5.25 18.75h-1.5a.75.75 0 010-1.5h1.5a.75.75 0 010 1.5zM3 12a.75.75 0 01.75-.75h7.5a.75.75 0 010 1.5h-7.5A.75.75 0 013 12zM9 3.75a2.25 2.25 0 100 4.5 2.25 2.25 0 000-4.5zM12.75 12a2.25 2.25 0 114.5 0 2.25 2.25 0 01-4.5 0zM9 15.75a2.25 2.25 0 100 4.5 2.25 2.25 0 000-4.5z" />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Extensions" class="text-red-700 dark:text-red-500">
            <:description>
              A suite of tools for you to <CalloutText.callout text="build your own" /> extensions and DSLs.
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M14.447 3.027a.75.75 0 01.527.92l-4.5 16.5a.75.75 0 01-1.448-.394l4.5-16.5a.75.75 0 01.921-.526zM16.72 6.22a.75.75 0 011.06 0l5.25 5.25a.75.75 0 010 1.06l-5.25 5.25a.75.75 0 11-1.06-1.06L21.44 12l-4.72-4.72a.75.75 0 010-1.06zm-9.44 0a.75.75 0 010 1.06L2.56 12l4.72 4.72a.75.75 0 11-1.06 1.06L.97 12.53a.75.75 0 010-1.06l5.25-5.25a.75.75 0 011.06 0z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Observability" class="text-green-700 dark:text-green-500">
            <:description>
              Custom tracers and rich telemetry events allow you to export <CalloutText.callout text="high fidelity observability data." />
            </:description>
            <:icon>
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor">
                <path
                  fill-rule="evenodd"
                  d="M10.5 3.75a6.75 6.75 0 100 13.5 6.75 6.75 0 000-13.5zM2.25 10.5a8.25 8.25 0 1114.59 5.28l4.69 4.69a.75.75 0 11-1.06 1.06l-4.69-4.69A8.25 8.25 0 012.25 10.5z"
                  clip-rule="evenodd"
                />
              </svg>
            </:icon>
          </Feature.feature>
          <Feature.feature name="Compatibility" class="text-purple-700 dark:text-purple-500">
            <:description>
              Works great with <CalloutText.callout text="Phoenix, Ecto" /> and all the other <CalloutText.callout text="first rate tools" /> in the Elixir ecosystem.
            </:description>
            <:icon>
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M14.25 6.087c0-.355.186-.676.401-.959.221-.29.349-.634.349-1.003 0-1.036-1.007-1.875-2.25-1.875s-2.25.84-2.25 1.875c0 .369.128.713.349 1.003.215.283.401.604.401.959v0a.64.64 0 01-.657.643 48.39 48.39 0 01-4.163-.3c.186 1.613.293 3.25.315 4.907a.656.656 0 01-.658.663v0c-.355 0-.676-.186-.959-.401a1.647 1.647 0 00-1.003-.349c-1.036 0-1.875 1.007-1.875 2.25s.84 2.25 1.875 2.25c.369 0 .713-.128 1.003-.349.283-.215.604-.401.959-.401v0c.31 0 .555.26.532.57a48.039 48.039 0 01-.642 5.056c1.518.19 3.058.309 4.616.354a.64.64 0 00.657-.643v0c0-.355-.186-.676-.401-.959a1.647 1.647 0 01-.349-1.003c0-1.035 1.008-1.875 2.25-1.875 1.243 0 2.25.84 2.25 1.875 0 .369-.128.713-.349 1.003-.215.283-.4.604-.4.959v0c0 .333.277.599.61.58a48.1 48.1 0 005.427-.63 48.05 48.05 0 00.582-4.717.532.532 0 00-.533-.57v0c-.355 0-.676.186-.959.401-.29.221-.634.349-1.003.349-1.035 0-1.875-1.007-1.875-2.25s.84-2.25 1.875-2.25c.37 0 .713.128 1.003.349.283.215.604.401.96.401v0a.656.656 0 00.658-.663 48.422 48.422 0 00-.37-5.36c-1.886.342-3.81.574-5.766.689a.578.578 0 01-.61-.58v0z"
                />
              </svg>
            </:icon>
          </Feature.feature>
        </div>

        <div class="flex flex-col mt-12 mb-2">
          <h2 class="mt-8 font-semibold text-red-500 dark:text-red-400 text-center">
            <a href="https://alembic.com.au/contact">
              Service delivery partner
            </a>
          </h2>
          <div class="flex flex-row justify-around mb-2">
            <p class="mt-4 text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
              <a href="https://alembic.com.au/contact">
                <img class="h-12 hover:opacity-80 cursor-pointer" src="/images/alembic.svg">
              </a>
            </p>
          </div>
          <div class="flex flex-row text-xl">
            <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6 text-center">
              <a href="https://alembic.com.au/contact"><CalloutText.callout text="Alembic" class="hover:opacity-70" /></a>
              specializes in providing custom solutions that ensure the success of your Ash Framework projects.
              Leveraging extensive knowledge of both Ash Framework and the broader Elixir ecosystem, our team is
              well-equipped to craft personalized projects, implement innovative features, or optimize your existing codebases.
              Reach out to learn more about how our tailored solutions can make your project excel.
            </p>
          </div>
        </div>

        <div class="my-8" />

        <div class="flex flex-col w-full dark:bg-none dark:bg-opacity-0 py-6">
          <div class="flex flex-col w-full">
            <div class="text-center w-full text-5xl font-bold text-black dark:text-white">
              Backed by our <CalloutText.callout text="sponsors" />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 items-center align-middle justify-items-center justify-center mt-12 gap-4 gap-y-12 mx-auto">
            <a class="block" href="https://coinbits.app/">
              <img class="h-8" src="/images/coinbits-logo.png">
            </a>
            <a class="block dark:hidden" href="https://www.wintermeyer-consulting.de/">
              <img class="h-8" src="/images/wintermeyer-logo.svg">
            </a>
            <a class="hidden dark:block" href="https://www.wintermeyer-consulting.de/">
              <img class="h-8" src="/images/wintermeyer-logo-dark.svg">
            </a>
            <a class="block dark:hidden" href="https://www.heretask.com/">
              <img class="h-8" src="/images/heretask-logo-light.svg">
            </a>
            <a class="hidden dark:block" href="https://www.heretask.com/">
              <img class="h-8" src="/images/heretask-logo-dark.svg">
            </a>
            <a class="block" href="https://www.groupflow.app">
              <img class="h-8" src="/images/group-flow-logo.svg">
            </a>
            <div class="hidden md:block">
            </div>
            <a class="block dark:hidden" href="https://www.zoonect.com/en/homepage">
              <img class="h-8" src="/images/zoonect-light.svg">
            </a>
            <a class="hidden dark:block" href="https://www.zoonect.com/en/homepage">
              <img class="h-8" src="/images/zoonect-dark.svg">
            </a>
          </div>
        </div>

        <!-- will unhide this when we have more logos -->
        <div class="hidden flex flex-col w-full dark:bg-none dark:bg-opacity-0 py-6">
          <div class="flex flex-col w-full">
            <div class="text-center w-full text-5xl font-bold text-black dark:text-white">
              Trusted by <CalloutText.callout text="many" />
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 items-center align-middle justify-items-center justify-center mt-12 gap-4 gap-y-12 mx-auto">
            <a class="block dark:hidden" href="www.plangora.com">
              <img class="h-8" src="/images/plangora-logo-light.jpg">
            </a>
            <a class="hidden dark:block" href="www.plangora.com">
              <img class="h-8" src="/images/plangora-logo-dark.png">
            </a>
            <a class="hidden" href="https://traveltechdeluxe.com">
              <img class="h-8" src="/images/travel-tech-deluxe-logo.png">
            </a>
          </div>
        </div>

        <div
          id="testimonials"
          class="flex flex-col items-center content-center w-full lg:w-[28rem] px-4 md:px-8 lg:px-0"
        >
          <.testimonial
            text="The ease of defining our domain model and configuring Ash to generate a powerful GraphQL API has been a game-changer. What used to be complex and time-consuming has become simplicity itself."
            author="Alan Heywood"
            title="CTO, HereTask"
          />

          <.testimonial
            text="Through its declarative extensibility, Ash delivers more than you'd expect: Powerful APIs with filtering/sorting/pagination/calculations/aggregations, pub/sub, authorization, rich introspection, GraphQL... It's what empowers this solo developer to build an ambitious ERP!"
            author="Frank Dugan III"
            title="System Specialist, SunnyCor Inc."
            class_overrides="md:-mt-20"
          />

          <.testimonial
            text="I’m constantly blown away with the quality of work and support the Ash community has put into this project. It’s gotten to the point that I can’t imagine starting a new Elixir project that doesn’t use Ash."
            author="Brett Kolodny"
            title="Full stack engineer, MEW"
            class_overrides="md:-mt-4"
          />

          <.testimonial
            text="Ash is an incredibly powerful idea that gives Alembic a massive competitive advantage. It empowers us to build wildly ambitious applications for our clients with tiny teams, while consistently delivering the high level of quality that our customers have come to expect."
            author="Josh Price"
            title="Technical Director, Alembic"
            class_overrides="md:-mt-20"
          />

          <.testimonial
            text="Ash Framework enabled us to build a robust platform for delivering financial services using bitcoin. Ash proved itself to our team by handling innovative use cases with ease and it continues to evolve ahead of our growing list of needs."
            author="Yousef Janajri"
            title="CTO & Co-Founder, Coinbits"
            class_overrides="md:-mt-4"
          />

          <.testimonial
            text="The more I’ve used Ash, the more blown away I am by how much I get out of it – and how little boilerplate I have to write. I’m yet to encounter a situation where I would need to fight the “Ash way” of doing things, but the framework still allows me to choose how I build my software."
            author="Juha Lehtonen"
            title="Senior Software Developer"
            class_overrides="md:-mt-20"
          />
        </div>

        <div class="flex flex-col text-center items-center mt-24">
          <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50 mb-16">
            It wouldn't be possible without our amazing community.<br>
            <CalloutText.callout text={"#{@contributor_count} contributors"} /> and counting!
          </p>

          <div class="grid mx-auto gap-3 grid-cols-6 sm:grid-cols-10 md:grid-cols-14">
            <%= for %{login: login, avatar_url: avatar_url, html_url: html_url} <- @contributors do %>
              <a href={html_url} class="flex flex-col items-center justify-center">
                <img class="h-12 w-12 rounded-full" src={avatar_url} alt={login}>
              </a>
            <% end %>
          </div>
          <a
            href="docs/guides/ash/latest/how_to/contribute"
            class="flex justify-center items-center w-full md:w-auto h-10 px-4 rounded-lg bg-primary-light-500 dark:bg-primary-dark-500 font-semibold dark:text-white dark:hover:bg-primary-dark-700 hover:bg-primary-light-700 mt-6"
          >
            Become a contributor
          </a>
        </div>

        <div class="block md:hidden my-12" />

        <div class="max-w-7xl px-4 sm:px-6 md:px-8 my-8 hidden sm:block">
          <h2 class="mt-8 font-semibold text-red-500 dark:text-red-400">
            Simple declarative DSL
          </h2>
          <p class="mt-4 text-3xl sm:text-4xl text-base-dark-900 font-extrabold tracking-tight dark:text-base-light-50">
            A taste of how to configure Ash
          </p>
          <p class="text-base-dark-500 dark:text-base-light-300 mt-4 max-w-3xl space-y-6">
            Below are some examples of the way you can model your resources with actions, attributes and relationships.
            You can easily swap data layers between Postgres or ETS for example, or add your own data layer extension.
            Once you've modelled your resources, you can derive GraphQL or JSON API external APIs from them.
          </p>
        </div>

        <div class="pt-6 pb-6 w-full max-w-6xl">
          <div class="flex flex-col lg:flex-row gap-10 mx-8 lg:mx-0">
            <.live_component module={CodeExample}
              id="define-a-resource"
              class="grow w-full lg:w-min max-w-[1000px]"
              code={post_example()}
              title="Define a resource"
            />
            <div class="flex flex-col gap-10 w-full">
              <div class="flex flex-col space-y-8">
                <.live_component module={CodeExample}
                  class="w-full"
                  collapsible
                  id="use-it-programmatically"
                  code={changeset_example()}
                  title="Use it programmatically"
                />
                <.live_component module={CodeExample}
                  class="w-auto"
                  collapsible
                  id="graphql-interface"
                  code={graphql_example()}
                  title="Add a GraphQL interface"
                />
                <.live_component module={CodeExample}
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="authorization-policies"
                  code={policies_example()}
                  title="Add authorization policies"
                />
                <.live_component module={CodeExample}
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="aggregates"
                  code={aggregate_example()}
                  title="Define aggregates and calculations"
                />
                <.live_component module={CodeExample}
                  class="w-auto"
                  collapsible
                  start_collapsed
                  id="pubsub"
                  code={notifier_example()}
                  title="Broadcast changes over Phoenix PubSub"
                />
                <.live_component module={CodeExample}
                  class="w-atuo"
                  collapsible
                  start_collapsed
                  id="live-view"
                  code={live_view_example()}
                  title="Use it with Phoenix LiveView"
                />
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr(:class_overrides, :string, default: "")
  attr :title, :string
  attr :author, :string
  attr :text, :string

  def testimonial(assigns) do
    ~H"""
    <div class={[
      "w-full md:w-[26rem] lg:min-w-fit lg:max-w-min rounded-xl shadow-xl dark:shadow-none mt-8 p-8
      odd:bg-base-light-200/80 even:bg-base-light-100/80 odd:dark:bg-base-dark-800/80 even:dark:bg-base-dark-700/80
      space-y-4 text-center md:text-left relative md:odd:-left-[10rem] md:even:left-[10rem]",
      @class_overrides
    ]}>
      <p class="text-lg font-light text-base-light-700 dark:text-base-dark-50 break-words">
        "<%= @text %>"
      </p>

      <p class="font-bold text-primary-light-500 dark:text-primary-dark-400">
        <%= @author %>
      </p>

      <p class="text-base-light-700 dark:text-base-dark-200">
        <%= @title %>
      </p>
    </div>
    """
  end

  def mount(socket) do
    contributors = AshHq.Github.Contributor.in_order!()

    {:ok,
     assign(
       socket,
       signed_up: false,
       contributor_count: Enum.count(contributors),
       contributors: contributors
     )}
  end

  def handle_event("toggle-theme", _, socket) do
    if socket.assigns.theme == :default do
      {:noreply, assign(socket, :theme, :dark)}
    else
      {:noreply, assign(socket, :theme, :default)}
    end
  end

  @changeset_example """
                     post = Example.Post.create!(%{
                       text: "Declarative programming is fun!"
                     })

                     Example.Post.react!(post, %{type: :like})

                     Example.Post
                     |> Ash.Query.filter(likes > 10)
                     |> Ash.Query.sort(likes: :desc)
                     |> Ash.read!()
                     """
                     |> to_code()

  defp changeset_example do
    @changeset_example
  end

  @live_view_example """
                     def mount(_params, _session, socket) do
                       form = AshPhoenix.Form.for_create(Example.Post, :create)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("validate", %{"form" => input}, socket) do
                       form = AshPhoenix.Form.validate(socket.assigns.form, input)

                       {:ok, assign(socket, :form, form)}
                     end

                     def handle_event("submit", _, socket) do
                       case AshPhoenix.Form.submit(socket.assigns.form) do
                         {:ok, post} ->
                           {:ok, redirect_to_post(socket, post)}

                         {:error, form_with_errors} ->
                           {:noreply, assign(socket, :form, form_with_errors)}
                       end
                     end
                     """
                     |> to_code()
  defp live_view_example do
    @live_view_example
  end

  @graphql_example """
                   graphql do
                     type :post

                     queries do
                       get :get_post, :read
                       list :feed, :read
                     end

                     mutations do
                       create :create_post, :create
                       update :react_to_post, :react
                     end
                   end
                   """
                   |> to_code()
  defp graphql_example do
    @graphql_example
  end

  @policies_example """
                    policies do
                      policy action_type(:read) do
                        authorize_if expr(visibility == :everyone)
                        authorize_if relates_to_actor_via([:author, :friends])
                      end
                    end
                    """
                    |> to_code()
  defp policies_example do
    @policies_example
  end

  @notifier_example """
                    pub_sub do
                      module ExampleEndpoint
                      prefix "post"

                      publish_all :create, ["created"]
                      publish :react, ["reaction", :id] event: "reaction"
                    end
                    """
                    |> to_code()
  defp notifier_example do
    @notifier_example
  end

  @aggregate_example """
                     aggregates do
                       count :likes, :reactions do
                         filter expr(type == :like)
                       end

                       count :dislikes, :reactions do
                         filter expr(type == :dislike)
                       end
                     end

                     calculations do
                       calculate :like_ratio, :float do
                         expr(likes / (likes + dislikes))
                       end
                     end
                     """
                     |> to_code()

  defp aggregate_example do
    @aggregate_example
  end

  @post_example """
                defmodule Example.Post do
                  use Ash.Resource,
                    domain: Example,
                    data_layer: AshPostgres.DataLayer

                  resource do
                    description "A post is the primary sharable entity in our system"
                  end

                  postgres do
                    table "posts"
                    repo Example.Repo
                  end

                  attributes do
                    attribute :text, :string do
                      allow_nil? false
                      description "The body of the text"
                    end

                    attribute :visibility, :atom do
                      constraints [
                        one_of: [:friends, :everyone]
                      ]
                      description "Which set of users this post should be visible to"
                    end
                  end

                  actions do
                    update :react do
                      argument :type, Example.Types.ReactionType do
                        allow_nil? false
                      end

                      change manage_relationship(
                        :type,
                        :reactions,
                        type: :append
                      )
                    end
                  end

                  relationships do
                    belongs_to :author, Example.User do
                      allow_nil? true
                    end

                    has_many :reactions, Example.Reaction
                  end
                end
                """
                |> to_code()

  defp post_example do
    @post_example
  end
end
