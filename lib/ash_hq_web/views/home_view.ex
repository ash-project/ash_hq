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
      Authentication: [
        password_auth: "Password",
        magic_link_auth: "Magic Link",
        oauth: "OAuth2"
      ],
      "Data Layers": [
        postgres: "PostgreSQL",
        sqlite: "SQLite",
        csv: "CSV"
      ],
      Finance: [
        money: "Money",
        double_entry: "Double Entry Accounting"
      ],
      Admin: [
        admin: "Admin UI"
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
      Observability: [
        appsignal: "AppSignal",
        opentelemetry: "OpenTelemetry"
      ],
      Testing: [
        smokestack: "Factories"
      ]
    ]
  end

  def coming_soon?(value), do: value in @coming_soon

  defp quickstarts do
    [live_view: "Phoenix LiveView", graphql: "GraphQL", json_api: "JSON:API"]
  end
end
