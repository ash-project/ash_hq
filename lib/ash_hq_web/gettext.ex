defmodule AshHqWeb.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](https://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import AshHqWeb.Gettext

      # Simple translation
      gettext("Here is the string to tranbase-dark")

      # Plural translation
      ngettext("Here is the string to tranbase-dark",
               "Here are the strings to tranbase-dark",
               3)

      # Domain-based translation
      dgettext("errors", "Here is the error message to tranbase-dark")

  See the [Gettext Docs](https://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :ash_hq
end
