defmodule AshHqWeb.HomeController do
  use AshHqWeb, :controller

  @url_base if Mix.env() == :dev, do: "localhost:4000/new/", else: "https://new.ash-hq.org/"

  def community(conn, _) do
    contributors = AshHq.Github.Contributor.in_order!()

    conn
    |> assign(:contributor_count, Enum.count(contributors))
    |> assign(:contributors, contributors)
    |> render("community.html")
  end

  def media(conn, _) do
    conn
    |> render("media.html")
  end

  def home(conn, _) do
    app_name = app_name()

    conn
    |> assign(:url_base, @url_base)
    |> assign(:app_name, app_name)
    |> assign(:safe_app_name, safe(app_name))
    |> render("home.html")
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
