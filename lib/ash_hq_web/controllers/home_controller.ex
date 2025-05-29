defmodule AshHqWeb.HomeController do
  use AshHqWeb, :controller

  @url_base if Mix.env() == :dev,
              do: "localhost:4000/install/",
              else: "https://ash-hq.org/install/"

  def blog_posts_and_case_studies do
    [
      %{
        title: "Transforming Healthcare Communication",
        description:
          "How Elixir and Ash Framework enabled a healthcare communication platform to scale and evolve.",
        url:
          "https://alembic.com.au/case-studies/transforming-healthcare-communication-with-elixir-and-ash-framework"
      },
      %{
        title: "From Paper to Precision Workflows",
        description:
          "A case study in digitizing and optimizing business workflows with modern technology.",
        url: "https://alembic.com.au/case-studies/from-paper-to-precision-workflows"
      },
      %{
        title: "Ash Framework",
        description:
          "An overview of Ash Framework and its capabilities for building robust applications.",
        url: "https://alembic.com.au/ash-framework"
      },
      %{
        title: "Multitenancy in Ash Framework",
        description: "A deep dive into implementing multitenancy solutions with Ash Framework.",
        url: "https://alembic.com.au/blog/multitenancy-in-ash-framework"
      },
      %{
        title: "Seeds with Ash Generators",
        description: "Learn how to use Ash generators to seed your application data effectively.",
        url: "https://alembic.com.au/blog/seeds-with-ash-generators-ashops"
      },
      %{
        title: "Ash Framework Book in Beta",
        description: "Explore the comprehensive guide to Ash Framework, now available in beta.",
        url: "https://alembic.com.au/blog/ash-framework-book-in-beta"
      }
    ]
  end

  def community(conn, _) do
    contributors = AshHq.Github.Contributor.in_order!()

    conn
    |> assign_events()
    |> assign(:contributor_count, Enum.count(contributors))
    |> assign(:contributors, contributors)
    |> render("community.html")
  end

  def media(conn, _) do
    conn
    |> assign_events()
    |> assign(:blog_posts_and_case_studies, blog_posts_and_case_studies())
    |> render("media.html")
  end

  def home(conn, _) do
    app_name = app_name()

    conn
    |> assign(:url_base, @url_base)
    |> assign(:app_name, app_name)
    |> assign_events()
    |> assign(:safe_app_name, safe(app_name))
    |> render("home.html")
  end

  def events(conn, _) do
    conn
    |> assign_events()
    |> render("events.html")
  end

  def book_errata(conn, _) do
    conn
    |> assign_events()
    |> render("book_errata.html")
  end

  defp assign_events(conn) do
    events = AshHq.Events.events()

    conn
    |> assign(:events_count, Enum.count(events))
    |> assign(:next_event, Enum.at(events, 0))
    |> assign(:events, events)
  end

  defp safe(name) do
    name
    |> String.downcase()
    |> String.replace(~r/[\s-]/, "_")
    |> String.replace(~r/[^a-z_]/, "")
    |> String.replace(~r/^_/, "")
  end

  defp app_name() do
    Enum.random([
      "Uber for Ice Cream",
      "Hairbnb",
      "Nietflix",
      "Lemonade Stand",
      "Toothpaste Subscription",
      "Pet Rock Rental",
      "Virtual Reality Yoga",
      "AI Personal Chef",
      "Drone Pizza Delivery",
      "Smart Fridge Inventory",
      "Blockchain Coffee",
      "Self-driving Lawn Mower",
      "Hamazon",
      "Jose Valim is my Hero"
    ])
  end
end
