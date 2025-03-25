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

  @coming_soon [:opentelemetry, :appsignal]
  @external [:oban, :mishka, :beacon]

  defp logos_grid, do: "grid-cols-3"

  defp logos do
    [
      Alembic: %{href: "https://www.alembic.com.au", src: "images/alembic.svg"},
      Daylite: %{
        href: "https://www.daylite.app",
        src: "/images/daylite-logo.svg"
      },
      Heretask: %{href: "https://www.heretask.com/", src: "/images/heretask-logo-light.svg"},
      GroupFlow: %{href: "https://www.groupflow.app", src: "/images/group-flow-logo.svg"},
      Zoonect: %{href: "https://www.zoonect.com/en/homepage", src: "/images/zoonect-dark.svg"},
      ScribbleVet: %{
        href: "https://www.scribblevet.com/",
        src: "/images/scribble-vet-logo.png"
      },
      Coinbits: %{href: "https://coinbits.app", src: "/images/coinbits-logo.png"},
      "Wintermeyer Consulting": %{
        href: "https://www.wintermeyer-consulting.de/",
        src: "/images/wintermeyer-logo-dark.svg"
      },
      # placeholder: %{href: "", src: ""},
      "Boring Business Leads": %{
        href: "https://boringbusinessleads.com",
        src: "/images/self-storage-leads-logo-light.svg"
      }
      # placeholder: %{href: "", src: ""}
    ]
    |> insert_placeholders(logos_grid())
  end

  defp insert_placeholders(items, class) do
    count =
      class
      |> String.reverse()
      |> Integer.parse()
      |> elem(0)
      |> Integer.digits()
      |> Enum.reverse()
      |> Enum.join("")
      |> String.to_integer()

    [first | rest] =
      items
      |> Enum.chunk_every(count)
      |> Enum.reverse()

    needed = count - Enum.count(first)

    if needed == 1 do
      {l, r} = Enum.split(first, div(count, 2))

      Enum.reverse([[l ++ [{:placeholder, %{href: "", src: ""}}] ++ r] | rest])
      |> List.flatten()
    else
      left = div(needed, 2)

      right =
        if rem(count, 2) == 1 do
          left + 1
        else
          left
        end

      new_first =
        Enum.concat([
          Stream.duplicate({:placeholder, %{href: "", src: ""}}, left),
          first,
          Stream.duplicate({:placeholder, %{href: "", src: ""}}, right)
        ])

      Enum.reverse([new_first | rest])
      |> List.flatten()
    end
  end

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
      "CMS & Admin": [
        beacon: "Beacon CMS",
        admin: "Admin UI"
      ],
      "UI Components": [
        mishka: "Mishka Chelekom"
      ],
      Observability: [
        appsignal: "AppSignal",
        opentelemetry: "OpenTelemetry"
      ]
    ]
  end

  def coming_soon?(value), do: value in @coming_soon
  def external?(value), do: value in @external

  defp quickstarts do
    [
      live_view: "Phoenix LiveView",
      graphql: "GraphQL",
      json_api: "JSON:API",
      postgres: "PostgreSQL"
    ]
  end
end
