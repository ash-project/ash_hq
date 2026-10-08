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
  echo "\n\033[32m$1\033[0m"
}

main() {
  elixir_version='1.18.0'
  elixir_otp_release='27'
  otp_version='27.1.2'
  root_dir="$HOME/.elixir-install"

  # Install Elixir if needed
  if command -v elixir >/dev/null 2>&1; then
    echo_heading "Elixir is already installed ✓"
    with_args=""
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
    with_args=""
  fi

  # Use 'mix' to install 'igniter_new' archive

  mix_cmd=$(command -v mix)

  if [ -z "$mix_cmd" ]; then
    echo "Error: mix command not found."
    exit 1
  fi

  echo_heading "Installing igniter_new archive..."
  mix archive.install hex igniter_new --force
  

  app_name="my_app"

  cli_args="$@"

   echo_heading "Creating new Elixir project '$app_name' with the following packages: ash,ash_postgres"
  mix igniter.new "$app_name" --with-args="${with_args}" --yes-to-deps --yes --setup --install "ash,ash_postgres" $cli_args --alpha --auth-strategy "magic_link" --zeta "one"
  
}

main "$@"
