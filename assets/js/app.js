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
    dependsOn: ['phoenix'],
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
    dependsOn: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy password']
  },
  magic_link_auth: {
    dependsOn: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy magic_link']
  },
  github_auth: {
    dependsOn: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "Set up Github Authentication",
      href: "https://hexdocs.pm/ash_authentication/github.html"
    }
  },
  auth0_auth: {
    dependsOn: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "Set up Auth0 Authentication",
      href: "https://hexdocs.pm/ash_authentication/auth0.html"
    }
  },
  other_oauth: {
    dependsOn: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "Set up Oauth Authentication",
      href: "https://hexdocs.pm/ash_authentication/auth0.html"
    }
  }

}

let appName = "my_app";

function setUrl() {
  let args = [];
  let packages = [];
  for (var feature of Object.keys(features)) {
    const config = features[feature];
    if (config.checked) {
      packages.push(...config.adds)
      args.push(...(config.args || []))
    }
  }
  packages = [...new Set(packages)];
  args = [...new Set(args)];

  const argsString = args.join(" ")
  let code = `sh <(curl 'https://new.ash-hq.org/${appName}?install=ash') && \\
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

  const el = document.getElementById('selected-features')
  console.log(el)
  el.innerHTML = code;
  console.log(el)
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

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
 liveSocket.disableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
