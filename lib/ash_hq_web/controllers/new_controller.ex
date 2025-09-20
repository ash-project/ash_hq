defmodule AshHqWeb.NewController do
  use AshHqWeb, :controller

  @template """
  # !/bin/sh
  #
  # To run locally without | sh:
  #
  #     $ curl -fsS -o myapp_new.sh https://ash-hq.org/new/myapp?install=list,of,packages
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

    # Check for Erlang 28 and require confirmation
    if command -v erl >/dev/null 2>&1; then
      erlang_version=$(erl -noshell -eval 'io:format("~s", [erlang:system_info(otp_release)]), halt().' 2>/dev/null || echo "unknown")
      if [ "$erlang_version" = "28" ]; then
        echo "\\n\\033[31m⚠️  WARNING: Erlang/OTP 28 is NOT officially supported ⚠️\\033[0m"
        echo "\\033[31mMany packages are not compatible with Erlang/OTP 28 and may fail to work correctly.\\033[0m"
        echo "\\033[33mWe recommend canceling this installation and using Erlang/OTP 27 instead.\\033[0m"
        echo "\\033[33mYou can install Erlang 27 using asdf, mise, or your system package manager.\\033[0m\\n"
        echo "\\033[1mDo you want to continue anyway? This is NOT recommended.\\033[0m"
        printf "Type 'yes' to continue or anything else to cancel: "
        read -r user_input
        if [ "$user_input" != "yes" ]; then
          echo "\\n\\033[32mGood choice! Please install Erlang/OTP 27 and try again.\\033[0m"
          exit 0
        fi
        echo "\\n\\033[31mProceeding with unsupported Erlang/OTP 28... you're on your own! 🤞\\033[0m\\n"
      fi
    fi

    # Install Elixir if needed
    if command -v elixir >/dev/null 2>&1; then
      echo_heading "Elixir is already installed ✓"
      with_args="<%= @with_args %>"
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
      with_args="<%= @new_with_args %>"
    fi

    # Use 'mix' to install 'igniter_new' archive

    mix_cmd=$(command -v mix)

    if [ -z "$mix_cmd" ]; then
      echo "Error: mix command not found."
      exit 1
    fi

    echo_heading "Installing igniter_new archive..."
    mix archive.install hex igniter_new --force
    <%= if @with_phx_new do %>
    latest_version=$(mix hex.info phx_new | grep "Releases:" | sed 's/.*Releases: //' | sed 's/,.*//')
    echo_heading "Installing Phoenix generator version $latest_version..."
    mix archive.install hex phx_new $latest_version --force<% end %>

    app_name="<%= @app_name %>"

    cli_args="$@"

    <%= if @install do %> echo_heading "Creating new Elixir project '$app_name' with the following packages: <%= @install %>"
    mix igniter.new "$app_name" --with-args=\"${with_args}\" <%= @with_arg %>--yes-to-deps --yes --setup --install "<%= @install %>" $cli_args <%= if @args do %><%= @args %><% end %>
    <% else %> echo_heading "Creating new Elixir project '$app_name'..."
    mix igniter.new "$app_name" --with-args=\"${with_args}\" <%= @with_arg %>--yes-to-deps --yes --setup $cli_args <%= if @args do %><%= @args %><% end %>
    <% end %>
  }

  main "$@"
  """

  def new_no_ash(conn, params) do
    new(conn, Map.put(params, "no_ash", true))
  end

  def new(conn, %{"name" => name} = params) do
    install =
      params["install"]
      |> Kernel.||("")
      |> String.split(",", trim: true)
      |> Enum.map(&String.trim/1)
      |> then(fn install ->
        if params["no_ash"] do
          install
        else
          Enum.concat(["ash"], install)
        end
      end)

    with_phx_new? = "phoenix" in install

    install = install -- ["phoenix"]

    install = Enum.join(install, ",")

    args =
      params
      |> Map.drop(["name", "install", "with_args", "no_ash"])
      |> Enum.map_join(" ", fn {key, value} ->
        if value == "true" do
          "--#{String.replace(key, "_", "-")}"
        else
          "--#{String.replace(key, "_", "-")} \"#{escape_unescaped_quotes(value)}\""
        end
      end)
      |> case do
        "" -> nil
        args -> args
      end

    new_with_args =
      if with_args = params["with_args"] do
        if with_phx_new? do
          "--from-elixir-install #{escape_unescaped_quotes(with_args)}"
        else
          "#{escape_unescaped_quotes(with_args)}"
        end
      else
        if with_phx_new? do
          "--from-elixir-install"
        else
          ""
        end
      end

    with_args =
      if with_args = params["with_args"] do
        "#{escape_unescaped_quotes(with_args)}"
      else
        ""
      end

    with_arg =
      if with_phx_new?, do: "--with phx.new "

    text =
      EEx.eval_string(@template,
        assigns: [
          with_phx_new: with_phx_new?,
          with_arg: with_arg,
          with_args: with_args,
          new_with_args: new_with_args,
          app_name: name,
          install: install,
          args: args
        ]
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
