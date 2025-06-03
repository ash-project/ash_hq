defmodule AshHqWeb.Components.Footer do
  @moduledoc """
  Footer component with helpful links for the Ash Framework site.
  """
  use Phoenix.Component

  def footer(assigns) do
    ~H"""
    <footer class="bg-slate-900 border-t border-slate-500/20 mt-auto">
      <div class="max-w-7xl mx-auto py-8 px-4 sm:px-6 lg:px-8">
        <div class="grid grid-cols-1 md:grid-cols-4 gap-8">
          <!-- Logo and Description -->
          <div class="col-span-1 md:col-span-2">
            <img src="/images/ash_logo_orange.svg" alt="Ash Framework" class="h-8 mb-4" />
            <p class="text-slate-400 text-sm max-w-md">
              A declarative, resource-oriented application framework for Elixir.
              Model your domain, derive the rest.
            </p>
          </div>

          <!-- Documentation Links -->
          <div>
            <h3 class="text-white font-semibold text-sm mb-4">Documentation</h3>
            <ul class="space-y-2 text-sm">
              <li>
                <a
                  href="https://hexdocs.pm/ash/get-started.html"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                >
                  Getting Started
                </a>
              </li>
              <li>
                <a
                  href="https://hexdocs.pm/ash/readme.html"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                >
                  Guides
                </a>
              </li>
              <li>
                <a
                  href="https://hexdocs.pm/ash/Ash.html"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                >
                  API Reference
                </a>
              </li>
            </ul>
          </div>

          <!-- Help & Support -->
          <div>
            <h3 class="text-white font-semibold text-sm mb-4">Help & Support</h3>
            <ul class="space-y-2 text-sm">
              <li>
                <a
                  href="/community"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                >
                  Community
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/ash-project/ash/issues/new?template=bug_report.md"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Report a Bug
                </a>
              </li>
              <li>
                <a
                  href="https://github.com/ash-project/ash?tab=security-ov-file#readme"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Security Policy
                </a>
              </li>
              <li>
                <a
                  href="https://alembic.com.au/services/ash-framework-premium-support"
                  class="text-slate-400 hover:text-primary-light-400 transition-colors"
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  Premium Support
                </a>
              </li>
            </ul>
          </div>
        </div>

        <!-- Bottom section -->
        <div class="mt-8 pt-8 border-t border-slate-500/20 flex flex-col md:flex-row justify-between items-center">
          <p class="text-slate-400 text-sm">
            © <%= Date.utc_today().year %> Ash Framework. Open source and built with ❤️
          </p>
          <div class="flex space-x-6 mt-4 md:mt-0">
            <a
              href="https://github.com/ash-project/ash"
              class="text-slate-400 hover:text-primary-light-400 transition-colors"
              target="_blank"
              rel="noopener noreferrer"
              title="GitHub"
            >
              <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
              </svg>
            </a>
            <a
              href="https://bsky.app/profile/ash-hq.org"
              class="text-slate-400 hover:text-primary-light-400 transition-colors"
              target="_blank"
              rel="noopener noreferrer"
              title="Bluesky"
            >
              <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 64 57">
                <path d="M13.873 3.805C21.21 9.332 29.103 20.537 32 26.55v15.882c0-.338-.13.044-.41.867-1.512 4.456-7.418 21.847-20.923 7.944-7.111-7.32-3.819-14.64 9.125-16.85-7.405 1.264-15.73-.825-18.014-9.015C1.12 23.022 0 8.51 0 6.55 0-3.268 8.579-.182 13.873 3.805ZM50.127 3.805C42.79 9.332 34.897 20.537 32 26.55v15.882c0-.338.13.044.41.867 1.512 4.456 7.418 21.847 20.923 7.944 7.111-7.32 3.819-14.64-9.125-16.85 7.405 1.264 15.73-.825 18.014-9.015C62.88 23.022 64 8.51 64 6.55c0-9.818-8.578-6.732-13.873-2.745Z"/>
              </svg>
            </a>
          </div>
        </div>
      </div>
    </footer>
    """
  end
end
