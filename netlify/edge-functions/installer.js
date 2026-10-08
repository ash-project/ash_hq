// Serves the installer scripts at /new/:name and /install/:name, e.g.
//
//     sh <(curl 'https://ash-hq.org/install/my_app?install=phoenix')
//
// /new adds Ash to the packages installed; /install doesn't. `install` is a comma-separated list
// of packages, `with_args` is passed through to the project generator, and any other parameter
// becomes a flag for `mix igniter.new` (`?example=true` → `--example`, `?foo=bar` → `--foo "bar"`).
//
// A port of the Phoenix app's NewController, producing exactly the same script for the same URL.
// The script is run by the shell, so every value must match an allowlist; anything else gets a
// script that prints an error and exits, rather than running code from a crafted URL.

export const config = { path: ["/new/*", "/install/*"], method: ["GET", "HEAD"] };

const APP_NAME = /^[A-Za-z][A-Za-z0-9_]*$/;
const PACKAGE = /^[A-Za-z0-9_.@:\/+-]+$/;
const ARG_NAME = /^[A-Za-z0-9_]+$/;
// Values end up inside double quotes, so nothing the shell would expand or terminate on
const ARG_VALUE = /^[A-Za-z0-9 _.,:=@\/+-]*$/;

const RESERVED_PARAMS = ["name", "install", "with_args", "no_ash"];

export default function handler(request) {
  const url = new URL(request.url);
  const match = url.pathname.match(/^\/(new|install)\/([^/]+)\/?$/);
  if (!match) return new Response("Not found", { status: 404 });

  const [, route, encodedName] = match;
  const params = Object.fromEntries(url.searchParams);
  const noAsh = route === "install" || "no_ash" in params;

  try {
    const script = installerScript(decodeURIComponent(encodedName), params, noAsh);
    return textResponse(script, 200);
  } catch (error) {
    if (!(error instanceof InvalidParam)) throw error;
    return textResponse(errorScript(error.message), 400);
  }
}

export function installerScript(appName, params, noAsh) {
  check(appName, APP_NAME, "app name");

  let packages = (params.install ?? "")
    .split(",")
    .map((name) => name.trim())
    .filter((name) => name !== "");
  packages.forEach((name) => check(name, PACKAGE, "package name"));
  if (!noAsh) packages = ["ash", ...packages];

  const withPhxNew = packages.includes("phoenix");
  const install = packages.filter((name) => name !== "phoenix").join(",");

  // Elixir sorts the keys of small maps, so the flags come out in key order
  const args = Object.keys(params)
    .filter((key) => !RESERVED_PARAMS.includes(key))
    .sort()
    .map((key) => {
      check(key, ARG_NAME, "parameter name");
      const value = check(params[key], ARG_VALUE, `value for ${key}`);
      const flag = `--${key.replaceAll("_", "-")}`;
      return value === "true" ? flag : `${flag} "${value}"`;
    })
    .join(" ");

  const withArgs = params.with_args === undefined ? "" : check(params.with_args, ARG_VALUE, "with_args");
  let newWithArgs = withArgs;
  if (withPhxNew) newWithArgs = withArgs === "" ? "--from-elixir-install" : `--from-elixir-install ${withArgs}`;
  const withArg = withPhxNew ? "--with phx.new " : "";

  const phxNew = withPhxNew
    ? `
  latest_version=$(mix hex.info phx_new | grep "Releases:" | sed 's/.*Releases: //' | sed 's/,.*//')
  echo_heading "Installing Phoenix generator version $latest_version..."
  mix archive.install hex phx_new $latest_version --force`
    : "";

  return `# !/bin/sh
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

  # Install Elixir if needed
  if command -v elixir >/dev/null 2>&1; then
    echo_heading "Elixir is already installed ✓"
    with_args="${withArgs}"
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
    with_args="${newWithArgs}"
  fi

  # Use 'mix' to install 'igniter_new' archive

  mix_cmd=$(command -v mix)

  if [ -z "$mix_cmd" ]; then
    echo "Error: mix command not found."
    exit 1
  fi

  echo_heading "Installing igniter_new archive..."
  mix archive.install hex igniter_new --force
  ${phxNew}

  app_name="${appName}"

  cli_args="$@"

   echo_heading "Creating new Elixir project '$app_name' with the following packages: ${install}"
  mix igniter.new "$app_name" --with-args="\${with_args}" ${withArg}--yes-to-deps --yes --setup --install "${install}" $cli_args ${args}
${"  "}
}

main "$@"
`;
}

// Runs harmlessly if someone pipes it into sh, unlike an HTML error page
function errorScript(message) {
  return `#!/bin/sh
echo "Error: invalid ${message} in the installer URL." >&2
echo "Letters, numbers, spaces and _ . , : = @ / + - are allowed." >&2
exit 1
`;
}

class InvalidParam extends Error {}

function check(value, pattern, description) {
  if (!pattern.test(value)) throw new InvalidParam(description);
  return value;
}

function textResponse(body, status) {
  return new Response(body, {
    status,
    headers: { "content-type": "text/plain; charset=utf-8", "content-disposition": "inline" },
  });
}
