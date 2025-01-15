defmodule AshHqWeb.HomeView do
  use AshHqWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  @coming_soon [:oban, :opentelemetry, :appsignal]

  defp features do
    [
      Web: [
        phoenix: "Phoenix",
        graphql: "GraphQL",
        json_api: "JSON:API"
      ],
      "Data Layers": [
        postgres: "PostgreSQL",
        sqlite: "SQLite",
        csv: "CSV"
      ],
      Authentication: [
        password_auth: "Password",
        magic_link_auth: "Magic Link",
        oauth: "OAuth2"
      ],
      Finance: [
        money: "Money",
        double_entry: "Double Entry Accounting"
      ],
      Automation: [
        oban: "Background Jobs",
        state_machine: "State Machines"
      ],
      "Safety & Security": [
        archival: "Archival",
        paper_trail: "Paper Trail",
        cloak: "Encryption"
      ],
      "Observability & Administration": [
        admin: "Admin UI",
        appsignal: "AppSignal",
        opentelemetry: "OpenTelemetry"
      ]
    ]
  end

  def coming_soon?(value), do: value in @coming_soon

  defp quickstarts do
    [
      live_view: "Phoenix LiveView",
      graphql: "GraphQL",
      json_api: "JSON:API",
      postgres: "PostgreSQL"
    ]
  end
end
