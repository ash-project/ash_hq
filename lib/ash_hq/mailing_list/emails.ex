defmodule AshHq.MailingList.Emails do
  @moduledoc """
  Delivers emails.
  """

  import Swoosh.Email

  def deliver_welcome_email(email) do
    deliver(email.email, "Thank you!", """
    <html>
      <p>
        Hi,
      </p>

      <p>
        Thank you so much for subscribing to the Ash Framework mailing list!
      </p>
      <p>
        We're excited to have you and we promise to use your email responsibly.
      </p>


      <p>
        Thanks again,
      </p>
      <p>
        The Ash Framework Team
      </p>
      <p>
        <a href="https://ash-hq.org/unsubscribe?email=#{URI.encode_www_form(to_string(email.email))}">unsubscribe</a>
      </p>
    </html>
    """)
  end

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
    new()
    |> from({"Zach", "zach@ash-hq.org"})
    |> to(to_string(to))
    |> subject(subject)
    |> html_body(body)
    |> AshHq.Mailer.deliver!()
  end
end
