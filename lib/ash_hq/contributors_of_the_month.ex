defmodule AshHq.ContributorsOfTheMonth do
  @moduledoc """
  Contributors of the month, most recent first.

  Each needs a unique `slug` (its certificate's URL) and a `name`. `github` (a login, for
  their avatar), `month` (any date in the month) and `reason` are optional.
  """

  @contributors [
    %{
      slug: "matt-beanland",
      name: "Matt Beanland",
      github: "matt-beanland",
      month: ~D[2026-10-01],
      reason: """
      Matt made major contributions to the temporal feature set. His work was the only reason we \
      were able to ship it on schedule, and he did a lot of hard work finding bugs and issues with \
      the initial implementation.
      """
    },
    %{
      slug: "jonatan-mannchen",
      name: "Jonatan Männchen",
      github: "maennchen",
      month: ~D[2024-08-01],
      reason: """
      Jonatan did a bunch of great work on bulk actions, including upsert conditions for bulk \
      creates and fixes to how batches are handled.
      """
    },
    %{
      slug: "rebecca-le",
      name: "Rebecca Le",
      github: "sevenseacat",
      month: ~D[2024-06-01],
      reason: """
      Rebecca is doing some seriously amazing work on the Ash book, but more importantly, she has \
      been providing excellent support to this community. It's great knowing that there are folks \
      watching out while I'm not around.
      """
    },
    %{
      slug: "robert-timis",
      name: "Robert Timis",
      github: "TimisRobert",
      month: ~D[2024-06-01],
      reason: """
      Robert has done excellent work on multiple packages, and also provided all kinds of great \
      test cases and high quality bug reports. Thank you for your hard work!
      """
    },
    %{
      slug: "riccardo-binetti",
      name: "Riccardo Binetti",
      github: "rbino",
      month: ~D[2024-06-01]
    },
    %{
      slug: "barnabas-jovanovics",
      name: "Barnabas Jovanovics",
      github: "barnabasJ",
      month: ~D[2023-10-01],
      reason: """
      Barnabas built subscriptions for AshGraphql, and has contributed a steady stream of fixes \
      and improvements across ash, ash_graphql and ash_postgres.
      """
    }
  ]

  def all, do: Enum.map(@contributors, &normalize/1)

  def get(slug), do: Enum.find(all(), &(&1.slug == slug))

  @doc "e.g. \"June 2024\", or nil when the month isn't known."
  def month_name(%{month: nil}), do: nil
  def month_name(%{month: month}), do: Calendar.strftime(month, "%B %Y")

  defp normalize(contributor) do
    Map.merge(%{github: nil, month: nil, reason: nil}, contributor)
    |> Map.update!(:reason, &(&1 && String.trim(&1)))
  end
end
