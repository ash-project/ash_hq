defmodule AshHq.MailingList.Emails do
  @moduledoc """
  Delivers emails.
  """

  import Swoosh.Email

  def deliver_welcome_email(email) do
    deliver(email.email, "Thank you!", """
    ==============================

    Hi,

    Thank you so much for subscribing to the Ash Framework mailing list!

    We're excited to have you and we promise to use your email responsibly.

    To unsubscribe visit the following link
    https://ash-hq.org/unsubscribe?email=#{URI.encode_www_form(to_string(email.email))}

    Thanks again,
    The Ash Framework Team
    ==============================
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
    |> text_body(body)
    |> AshHq.Mailer.deliver!()
    |> IO.inspect()
  end
end
