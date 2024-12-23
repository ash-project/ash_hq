// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
import scrollIntoView from "smooth-scroll-into-view-if-needed";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

const Hooks = {};

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken, user_agent: window.navigator.userAgent },
  hooks: Hooks,
  metadata: {
    keydown: (e) => {
      return {
        key: e.key,
        metaKey: e.metaKey,
      };
    },
  },
});

const features = {
  // special case that this adds `with`
  phoenix: {
    adds: ['ash_phoenix']
  },
  graphql: {
    requires: ['phoenix'],
    adds: ['ash_graphql']
  },
  postgres: {
    adds: ['ash_postgres']
  },
  sqlite: {
    adds: ['ash_sqlite']
  },
  money: {
    after: ['postgres'],
    adds: ['ash_money']
  },
  password_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy password']
  },
  magic_link_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy magic_link']
  },
  github_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "GitHub Auth",
      href: "https://hexdocs.pm/ash_authentication/github.html"
    }
  },
  auth0_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "Auth0 Auth",
      href: "https://hexdocs.pm/ash_authentication/auth0.html"
    }
  },
  other_oauth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "Other OAuth",
      href: "https://hexdocs.pm/ash_authentication/auth0.html"
    }
  }
}

let appName = "my_app";

function setUrl() {
  var button = document.getElementById('copy-url-button');
  var icon = document.getElementById('copy-url-button-icon');
  var text = document.getElementById('copy-url-button-text');

  text.innerHTML = "Copy"
  icon.classList.remove("hero-check")
  icon.classList.add("hero-clipboard")
  button.classList.remove("was-clicked");

  let args = [];
  let packages = [];
  let disabled = [];
  let setups = [];

  for (var feature of Object.keys(features)) {
    const config = features[feature];
    if (config.checked) {
      (config.requires || []).forEach((requirement) => {
        const requiredConfig = features[requirement]
        packages.push(...requiredConfig.adds);
        args.push(...(requiredConfig.args || []));

        if (requiredConfig.requiresSetup) {
          setups.push(`<a target="_blank" class="link" href="${requiredConfig.requiresSetup.href}">${requiredConfig.requiresSetup.name}</a>`)
        }

        const checkboxId = `feature-${requirement}`

        const requiredCheckbox = document.getElementById(checkboxId)

        requiredCheckbox.checked = true;
        requiredCheckbox.disabled = true;
        disabled.push(checkboxId)
        features[feature].checked = true;
      })

      packages.push(...config.adds);
      args.push(...(config.args || []));

      if (config.requiresSetup) {
        setups.push(`<a target="_blank" class="link" href="${config.requiresSetup.href}">${config.requiresSetup.name}</a>`)
      }
    }
  }

  [...document.querySelectorAll(".feature-checkbox:disabled")].forEach((el) => {
    if (!disabled.includes(el.id)) {
      el.disabled = false
    }
  })

  packages = [...new Set(packages)];
  args = [...new Set(args)];
  setups = [...new Set(setups)];

  let withParam = ""; 
  if(features.phoenix.checked) {
    withParam = "&with=phx.new"
  }

  const argsString = args.join(" ")
  let code = `sh <(curl 'https://new.ash-hq.org/${appName}?install=ash${withParam}') && \\
    cd ${appName}`

  if (packages.length !== 0) {
    code = code + ` && 
    mix igniter.install \\`
  }

  packages.forEach((pack) => {
    code = code + `
    ${pack} \\`
  });

  args.forEach((arg) => {
    code = code + `
    ${arg} \\`
  });

  if (args.length !== 0 || packages.length !== 0) {
    code = code.substring(0, code.length - 1);
  }

  const manualSetupBox = document.getElementById("manual-setup-box")

  if (setups.length === 0) {
    manualSetupBox.classList.add("hidden")
  } else {
    manualSetupBox.classList.remove("hidden")
    const manualSetupLinks = document.getElementById("manual-setup-links")
    setups.forEach((setup) => {
      manualSetupLinks.innerHTML = setups.join("");
    })
  }

  const el = document.getElementById('selected-features')
  el.innerHTML = code;
}

window.featureClicked = function(el) {
  const name = el.value;
  const checked = el.checked;
  features[name].checked = checked;
  setUrl()
}

window.appNameChanged = function(el) {
  appName = el.value;

  setUrl()
}

window.copyUrl = function(el) {
  // Get the text field
  var copyText = document.getElementById('selected-features').innerHTML;

  copyText = copyText
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&');

  navigator.clipboard.writeText(copyText);

  var button = document.getElementById('copy-url-button');
  var icon = document.getElementById('copy-url-button-icon');
  var text = document.getElementById('copy-url-button-text');

  text.innerHTML = "Copied"
  icon.classList.remove("hero-clipboard")
  icon.classList.add("hero-check")
  button.classList.add("was-clicked");
}

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
 liveSocket.disableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
