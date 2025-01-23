defmodule AshHq.Events do
  @events [
            %{
              cta: "Tickets On Sale Now!",
              title: "Ash Training @ CodeBeam US",
              description: """
              <p class="font-bold" >
                Supercharge Your Elixir Apps with Ash
              </p>
              <p>
                Level up on Ash and hang out with the Ash team at CodeBeam US in San Francisco CA!
              </p>
              """,
              date: ~D[2025-03-05],
              date_in_english: "March 5th, 2025",
              href: "https://codebeamamerica.com/trainings/supercharge-your-elixir-apps-with-ash/"
            },
            %{
              title: "Ash Training @ AlchemyConf",
              description: """
              <p class="font-bold">
                Supercharge Your Elixir Apps with Ash
              </p>
              <p>
                Level up on Ash and hang out with the Ash team at AlchemyConf in Braga Portugal!
              </p>
              """,
              date: ~D[2025-04-01],
              date_in_english: "April 1st, 2025",
              href: "https://codebeamamerica.com/trainings/supercharge-your-elixir-apps-with-ash/"
            },
            %{
              title: "Talk @ GigCityElixir 2025",
              description: """
              <p class="font-bold">
                Ash, Igniter and the Middle Way
              </p>
              <p>
                Zach gives a talk on the future of Ash and Igniter, and a first foray into new concepts.
              </p>
              """,
              date: ~D[2025-05-05],
              date_in_english: "May 5th, 2025",
              href: "https://www.gigcityelixir.com"
            },
            %{
              title: "Talk @ ElixirConf EU",
              description: """
              <p class="font-bold">
                The Next Dimension of Developer Experience
              </p>
              <p>
                Zach gives a talk on Igniter and the massive improvement it can make to the Elixir DX!
              </p>
              """,
              date: ~D[2025-05-15],
              date_in_english: "May 15th, 2025",
              href: "https://www.elixirconf.eu"
            },
            %{
              title: "Talk @ GOATMIRE",
              description: """
              <p class="font-bold">
                Talk title is a secret ;)
              </p>
              <p>
                Hang out with Zach in Varberg, Sweden
              </p>
              """,
              date: ~D[2025-09-10],
              date_in_english: "September 10th, 2025",
              href: "https://goatmire.com"
            }
          ]
          |> Enum.sort_by(& &1.date, Date)

  def events do
    today = Date.utc_today()

    @events
    |> Enum.reject(&(Date.compare(today, &1.date) == :gt))
  end
end
