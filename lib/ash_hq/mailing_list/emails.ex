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

  def send_tshirt_blast(opts \\ []) do
    email = """
    <html>
      <h1>
        Hello!
      </h1>

      <p>
        Thank you for being one of the first 100 people to sign up for the AshHq mailing list! As
        promised at ElixirConf this year, you're all eligible to receive a free Ash Framework T-shirt!
      </p>

      <p>
        To receive your shirt:
      </p>

      <p>
        <ul>
          <li>
            Head over to <a href="https://ash-hq.org/users/register">Ash HQ</a> and register for an account
          </li>
          <li>
            Go to the user settings page, and input your name, shirt size, and address.
          </li>
          <li>
            We will send you an email once your shirt is on the way!
          </li>
        </ul>
      </p>

      <p>
      Your name and address are stored securely and will not be used for anything other than sending you your merch.
      <br>
      We appreciate your patience as we figure out all the details, we want to make sure that this is seamless for everyone and that the shirts are of the utmost quality.
      </p>
      <p style="padding-top: 40">
        Thank you for your support,
        <br>
        The Ash Framework Team
      </p>
      <p>
        <img src="https://ash-hq.org/images/ash-logo-side.png" alt="Ash Framework" title="Ash Framework" style="display:block" width="200" />
      </p>
    </html>
    """

    send_blast("Ash Framework T-Shirts!", email, opts)
  end

  def send_blast(subject, contents, opts \\ []) do
    receivers =
      if opts[:really_send?] do
        opts[:to] ||
          AshHq.MailingList.Email.all!()
          |> Enum.map(&to_string(&1.email))
      else
        opts[:to] || ["zachary.s.daniel@gmail.com", "zach@alembic.com.au"]
      end

    Enum.map(receivers, fn receiver ->
      new()
      |> from({"Zach @ AshHQ", "news@ash-hq.org"})
      |> to(receiver)
      |> subject(subject)
      |> put_provider_option(:message_stream, "broadcast")
      |> put_provider_option(:track_links, "None")
      |> html_body(contents)
    end)
    |> AshHq.MailingList.Mailer.deliver_many()
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
    |> put_provider_option(:track_links, "None")
    |> html_body(body)
    |> AshHq.Mailer.deliver!()
  end
end
