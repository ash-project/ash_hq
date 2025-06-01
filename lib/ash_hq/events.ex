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
              href: "https://membrz.club/alchemyconf/events/supercharge-your-elixir-apps-with-ash"
            },
            %{
              title: "Training @ GigCityElixir 2025",
              description: """
              <p class="font-bold">
                Supercharge Your Elixir Apps with Ash
              </p>
              <p>
                Level up on Ash and hang out with the Ash team at AlchemyConf in Braga Portugal!
              </p>
              """,
              date: ~D[2025-05-08],
              date_in_english: "May 8th, 2025",
              href: "https://www.gigcityelixir.com"
            },
            %{
              title: "Talk @ GigCityElixir 2025",
              description: """
              <p class="font-bold">
                The Next Dimension of Developer Experience
              </p>
              <p>
                Zach gives a talk on Igniter and the massive improvement it can make to the Elixir DX!
              </p>
              """,
              date: ~D[2025-05-09],
              date_in_english: "May 9th, 2025",
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
              title:
                "Building on Bedrock: Elixir's Fundamental Design Advantage @ Scenic City Summit",
              description: """
              <p class="font-bold">
                Building on Bedrock: Elixir's Fundamental Design Advantage
              </p>
              <p>
                Zach gives a talk about Elixir, exploring the small design choices underpinning Elixir that manifest in exponentially more efficient and understandable applications. Understanding why Elixir manages to be so productive and effective.
              </p>
              """,
              date: ~D[2025-06-20],
              date_in_english: "June 20th, 2025",
              href: "https://sceniccitysummit.com"
            },
            %{
              title:
                "Building on Bedrock: Elixir's Fundamental Design Advantage @ Carolina Codes",
              description: """
              <p class="font-bold">
                Building on Bedrock: Elixir's Fundamental Design Advantage
              </p>
              <p>
                Zach gives a talk about Elixir, exploring the small design choices underpinning Elixir that manifest in exponentially more efficient and understandable applications. Understanding why Elixir manages to be so productive and effective.
              </p>
              """,
              date: ~D[2025-08-16],
              date_in_english: "August 16th, 2025",
              href: "https://blog.carolina.codes/p/announcing-our-2025-speakers"
            },
            %{
              title: "Ash AI Hackathon @ ElixirConf US",
              description: """
              <p class="font-bold">
                Ash AI Hackathon
              </p>
              <p>
                Join Zach & Josh for an introduction to Ash AI followed by a free-form hackathon on AI apps with Ash.
              </p>
              """,
              date: ~D[2025-08-27],
              date_in_english: "August 27th, 2025",
              href: "https://elixirconf.com/trainings/ash-ai-hackathon/"
            },
            %{
              title: "Talk @ GOATMIRE",
              description: """
              <p class="font-bold">
                Talk title is a secret ;)
              </p>
              <p>
                Hang out with Zach, Rebecca, Barnabas, James and Josh from the Ash core team in Varberg, Sweden
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
