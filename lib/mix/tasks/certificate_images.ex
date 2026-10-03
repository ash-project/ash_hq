defmodule Mix.Tasks.AshHq.CertificateImages do
  @shortdoc "Screenshots contributor of the month certificates, for link previews."
  @moduledoc """
  #{@shortdoc}

  Run it after adding a contributor of the month, with the server running. Each certificate is
  saved to `priv/static/images/contributors-of-the-month/<slug>.png`, and used as the `og:image`
  of its page once it exists.

      mix ash_hq.certificate_images [slug ...] [--url http://localhost:4000]

  With no slugs, only certificates without an image yet are screenshotted. Uses Google Chrome,
  or whatever the `CHROME` environment variable points at.
  """
  use Mix.Task

  @requirements ["compile"]

  # Letter, landscape, at 120px per inch
  @window_size "1320,1020"

  @impl Mix.Task
  def run(args) do
    {opts, slugs} = OptionParser.parse!(args, strict: [url: :string])
    url = Keyword.get(opts, :url, "http://localhost:4000")
    chrome = chrome!()

    contributors =
      case slugs do
        [] ->
          Enum.reject(AshHq.ContributorsOfTheMonth.all(), &File.exists?(image_file(&1)))

        slugs ->
          Enum.map(slugs, fn slug ->
            AshHq.ContributorsOfTheMonth.get(slug) ||
              Mix.raise("No contributor of the month with the slug #{inspect(slug)}")
          end)
      end

    if contributors == [], do: Mix.shell().info("All certificates already have images.")

    Enum.each(contributors, fn contributor ->
      file = image_file(contributor)
      File.mkdir_p!(Path.dirname(file))

      {output, status} =
        System.cmd(
          chrome,
          [
            "--headless=new",
            "--disable-gpu",
            "--hide-scrollbars",
            "--window-size=#{@window_size}",
            "--virtual-time-budget=5000",
            "--screenshot=#{Path.expand(file)}",
            "#{url}/community/contributors-of-the-month/#{contributor.slug}?image=true"
          ],
          stderr_to_stdout: true
        )

      if status != 0 or not File.exists?(file) do
        Mix.raise("Could not screenshot #{contributor.slug}, is the server running?\n\n#{output}")
      end

      Mix.shell().info("Wrote #{file}")
    end)
  end

  defp image_file(contributor) do
    Path.join("priv/static", AshHq.ContributorsOfTheMonth.image_path(contributor))
  end

  defp chrome! do
    [
      System.get_env("CHROME"),
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
      System.find_executable("google-chrome"),
      System.find_executable("chromium")
    ]
    |> Enum.find(&(&1 && File.exists?(&1))) ||
      Mix.raise("Could not find Chrome, set the CHROME environment variable to its path")
  end
end
