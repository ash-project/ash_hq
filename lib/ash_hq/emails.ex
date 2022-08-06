defmodule AshHq.Emails do
  import Bamboo.Email
  use Bamboo.Phoenix, view: AshHqWeb.EmailView

  @from "test@example.com"

  def welcome_email(%{email: email}) do
    base_email()
    |> subject("Welcome!")
    |> to(email)
    |> render("welcome.html",
      title: "Thank you for signing up",
      preheader: "Thank you for signing up to the app."
    )
    |> premail()
  end

  defp base_email do
    new_email()
    |> from(@from)
    # Set default layout
    |> put_html_layout({AshHqWeb.LayoutView, "email.html"})
    # Set default text layout
    |> put_text_layout({AshHqWeb.LayoutView, "email.text"})
  end

  defp premail(email) do
    html = Premailex.to_inline_css(email.html_body)
    text = Premailex.to_text(email.html_body)

    email
    |> html_body(html)
    |> text_body(text)
  end
end
