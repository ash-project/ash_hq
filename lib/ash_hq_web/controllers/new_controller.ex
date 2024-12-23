defmodule AshHqWeb.NewController do
  use AshHqWeb, :controller

  @template """
  # !/bin/sh
  #
  # To run locally without | sh:
  #
  #     $ curl -fsS -o myapp_new.sh https://new.ash-hq.org/myapp?install=list,of,packages
  #     $ sh myapp_new.sh
  #
  # Installs Elixir from Elixir's official install.sh script, then runs igniter.new.
  #
  # See latest Elixir install.sh version at:
  # https://github.com/elixir-lang/elixir-lang.github.com/blob/main/install.sh
  set -eu

  echo_heading() {
    echo "\\n\\033[32m$1\\033[0m"
  }

  main() {
    elixir_version='1.18.0'
    elixir_otp_release='27'
    otp_version='27.1.2'
    root_dir="$HOME/.elixir-install"

    # Install Elixir if needed
    if command -v elixir >/dev/null 2>&1; then
      echo_heading "Elixir is already installed ✓"
    else
      echo_heading "Installing Elixir..."

      if [ ! -d "$root_dir" ]; then
        mkdir -p "$root_dir"
      fi

      curl -fsSo "$root_dir/install.sh" "https://elixir-lang.org/install.sh"

      (
        sh $root_dir/install.sh "elixir@$elixir_version" "otp@$otp_version"
      )
      if [ $? -ne 0 ]; then
        echo "Failed to install elixir"
        exit 1
      fi
      # Export the PATH so the current shell can find 'elixir' and 'mix'
      export PATH=$HOME/.elixir-install/installs/otp/$otp_version/bin:$PATH
      export PATH=$HOME/.elixir-install/installs/elixir/$elixir_version-otp-$elixir_otp_release/bin:$PATH
    fi

    # Use 'mix' to install 'igniter_new' archive

    mix_cmd=$(command -v mix)

    if [ -z "$mix_cmd" ]; then
      echo "Error: mix command not found."
      exit 1
    fi

    echo_heading "Installing igniter_new archive..."
    mix archive.install hex igniter_new --force
    <%= if @with_phx_new do %>mix archive.install hex phx_new --force<% end %>

    app_name="<%= @app_name %>"

    cli_args="$@"

    <%= if @install do %> echo_heading "Creating new Elixir project '$app_name' with the following packages: <%= @install %>"
    mix igniter.new "$app_name" --yes --install "<%= @install %>" $cli_args <%= if @args do %><%= @args %><% end %>
    <% else %> echo_heading "Creating new Elixir project '$app_name'..."
    mix igniter.new "$app_name" --yes $cli_args <%= if @args do %><%= @args %><% end %>
    <% end %>

    echo "Your app is ready at \\`./$app_name\\`"
  }

  main "$@"
  """

  def new(conn, %{"name" => name} = params) do
    install =
      params["install"]
      |> Kernel.||("")
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.join(",")
      |> case do
        "" -> nil
        install -> install
      end

    with_phx_new? =
      params["with"] == "phx.new"

    args =
      params
      |> Map.drop(["name", "install"])
      |> Enum.map_join(" ", fn {key, value} ->
        "--#{String.replace(key, "_", "-")} \"#{escape_unescaped_quotes(value)}\""
      end)
      |> case do
        "" -> nil
        args -> args
      end

    text =
      EEx.eval_string(@template,
        assigns: [with_phx_new: with_phx_new?, app_name: name, install: install, args: args]
      )

    conn
    |> put_resp_content_type("text/plain; charset=utf-8")
    |> put_resp_header("content-disposition", "inline")
    |> send_resp(200, text)
  end

  def escape_unescaped_quotes(string) do
    Regex.replace(~r/(?<!\\)"/, string, "\\\"")
  end
end
