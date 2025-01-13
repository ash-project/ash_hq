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
import tippy from 'tippy.js';
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

const quickstarts = {
  live_view: {
    tooltip: `
    <p class="mb-2">
    Full stack Elixir!
    </p>
    <p>
    Perfect for the Elixir maximalist.
    </p>
    `,
    features: ['phoenix', 'postgres', 'magic_link_auth', 'admin'],
  },
  graphql: {
    features: ['phoenix', 'graphql', 'postgres', 'admin'],
    tooltip: `
    <p class="mb-2">
    A GraphQL API, a database and a dream.
    </p>
    <p>
    All the power of GraphQL, none of the boilerplate.
    </p>
    `
  },
  json_api: {
    features: ['phoenix', 'json_api', 'postgres', 'admin'],
    tooltip: `
    <p class="mb-2">
    JSON:API. Simple, battle-tested, effective.
    </p>
    <p>
    Create a simple yet elegant REST API, complete with an Open API spec!
    </p>
    `
  }
}

const features = {
  phoenix: {
    adds: ['phoenix', 'ash_phoenix'],
    tooltip: `
    <p class="mb-2">
    Ash works seamlessly with Phoenix. 
    </p>
    <p>
    Phoenix is your web layer, Ash is your application layer.
    </p>
    ` 
  },
  graphql: {
    requires: ['phoenix'],
    adds: ['ash_graphql'],
    tooltip: `
    <p class="mb-2">
    Create a powerful and flexible GraphQL API directly from your resources.
    </p>
    <p>
    Built on top of the excellent library Absinthe.
    No need for writing data loaders, resolvers or middleware!
    </p>
    ` 
  },
  json_api: {
    requires: ['phoenix'],
    adds: ['ash_json_api'],
    tooltip: `
    <p class="mb-2">
    Easily create a spec-compliant JSON:API, directly from your resources. 
    </p>
    <p>
    Generates an OpenAPI specification automatically, allowing easy integration with all kinds of tools and services.
    </p>
    ` 

  },
  postgres: {
    adds: ['ash_postgres'],
    tooltip: `
    <p class="mb-2">
    PostgreSQL
    </p>
    <p>
    The swiss army knife of databases. Versatile, powerful, and battle-tested.
    </p>
    `
  },
  sqlite: {
    adds: ['ash_sqlite'],
    tooltip: `
    <p class="mb-2">
    SQLite
    </p>
    <p>
    Small, fast, and reliable. Perfect for lightweight apps or getting started quickly.
    </p>
    `
  },
  password_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy password'],
    tooltip: `
    <p class="mb-2">
    Allow users to log in with email & password.
    </p>
    <p>
    Ships with email confirmation, password resets, and registration out of the box!
    </p>
    `
  },
  magic_link_auth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    args: ['--auth-strategy magic_link'],
    tooltip: `
    <p class="mb-2">
    Send users a link in their email to sign in and register.
    </p>
    <p>
    Who needs the complexity of emails & passwords? Keep it simple with magic links.
    </p>
    `
  },
  oauth: {
    requires: ['phoenix'],
    adds: ['ash_authentication', 'ash_authentication_phoenix'],
    requiresSetup: {
      name: "OAuth",
      href: "https://hexdocs.pm/ash_authentication"
    },
    tooltip: `
    <p class="mb-2">
    Sign in using an external service.
    </p>
    <p>
    Supports any OAuth2 provider with premade configurations for Apple, Google, Github, Auth0, Oidc, and Slack.
    </p>
    `
  },
  money: {
    adds: ['ash_money'],
    after: ['ash_postgres'],
    tooltip: `
    <p class="mb-2">
    A data type for representing money $$$$.
    </p>
    <p>
    Ships with a postgres datatype, and operator and function definitions!
    </p>
    `
  },
  csv: {
    adds: ['ash_csv'],
    tooltip: `
    <p class="mb-2">
    Back resources with CSV files.
    </p>
    <p>
    Easily interact with CSV files in code, or turn a CSV file into an API in minutes.
    </p>
    `
  },
  admin: {
    adds: ['ash_admin'],
    tooltip: `
    <p class="mb-2">
    A zero-config-necessary super admin UI.
    </p>
    <p>
    Call any resource action from an automatically generated web UI
    </p>
    `
  },
  double_entry: {
    requires: ['money'],
    adds: ['ash_double_entry'],
    tooltip: `
    <p class="mb-2">
    Moving money around? Need to track financial data?
    </p>
    <p>
    Provides a data model for double entry accounting that can be extended to fit your own needs.
    </p>
    `
  }
}

for (var quickstart of Object.keys(quickstarts)) {
  const tooltip = quickstarts[quickstart].tooltip
  if (tooltip) {
    addTooltip(`#quickstart-${quickstart}`, tooltip)
  }
}

for (var feature of Object.keys(features)) {
  const tooltip = features[feature].tooltip

  if (tooltip) {
    addTooltip(`#feature-${feature}`, tooltip)
  }
}

addTooltip("#advanced-help", `
  <p class="mb-3">
    Can't decide? Don't fret! 
  </p>
  <p>
    Everything but Phoenix can be installed later when you need it.
  </p>
  `
)

function addTooltip(id, content) {
  const div = document.createElement('div')
  div.classList.add("bg-slate-800", "rounded-lg", "p-2", "border", "border-slate-950", "shadow-lg", "shadow-slate-950/80", "text-center");
  div.innerHTML = content;
  const boundary = document.getElementById("#installer-bounds")
  tippy(id, {
    content: div,
    hideOnClick: false,
    animation: false,
    allowHTML: true,
    delay: 0,
    popperOptions: {
      modifiers: [

        {
          name: 'flip',
          options: {
            padding: {
              top: 64
            }
          },
        },
      ],
    },
  });
}

let appName = "awesome_app";

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

        const activeBox = document.getElementById(`feature-${requirement}-active`)
        const inactiveBox = document.getElementById(`feature-${requirement}-inactive`)

        activeBox.classList.remove("hidden")
        inactiveBox.classList.add("hidden")

        activeBox.classList.add("ring-2", "ring-primary-dark-800")

        features[requirement].checked = true;
        disabled.push(requirement)

        features[feature].checked = true;
      })

      packages.push(...config.adds);
      args.push(...(config.args || []));

      if (config.requiresSetup) {
        setups.push(`<a target="_blank" class="link" href="${config.requiresSetup.href}">${config.requiresSetup.name}</a>`)
      }
    }
  }


  [...document.querySelectorAll(".active-feature")].forEach((el) => {
    if (!disabled.includes(el.dataset.name)) {
      el.classList.remove("ring-2", "ring-primary-dark-800")
    }
  })


  packages = [...new Set(packages)];
  args = [...new Set(args)];
  setups = [...new Set(setups)];

  let base
  if (location.hostname === "localhost" || location.hostname === "127.0.0.1") {
    base = "localhost:4000/new"
  } else {
    base = "https://new.ash-hq.org"
  }

  const argsString = args.join(" ")
  let code = `curl '${base}/${appName}' | sh < /dev/tty <&- && \\
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

window.featureClicked = function(el, toggleTo, checked) {
  const name = el.dataset.name;
  features[name].checked = checked;
  el.classList.add("hidden")
  document.getElementById(toggleTo).classList.remove("hidden")

  setUrl()
}

window.quickStartClicked = function(el, toggleTo, checked) {
  [...document.querySelectorAll(".active-quickstart")].forEach((el) => {
    el.classList.add("hidden")
  });

  [...document.querySelectorAll(".inactive-quickstart")].forEach((el) => {
    el.classList.remove("hidden")
  });

  [...document.querySelectorAll(".active-feature")].forEach((el) => {
    el.classList.add("hidden")
  });

  [...document.querySelectorAll(".inactive-feature")].forEach((el) => {
    el.classList.remove("hidden")
  });

  el.classList.add("hidden")
  document.getElementById(toggleTo).classList.remove("hidden");

  for (var feature of Object.keys(features)) {
    features[feature].checked = false
  }

  const toClick = quickstarts[el.dataset.name].features;

  if(checked) {
    toClick.forEach((name) => {
      document.getElementById(`feature-${name}-inactive`).click()
    })
  }

  setUrl()
}

window.appNameChanged = function(el) {
  appName = el.value;

  setUrl()
}

window.showAdvancedFeatures = function() {
  const chevron = document.getElementById("advanced-chevron");
  const text = document.getElementById("advanced-text")
  const advanced = document.getElementById("advanced-features")
  console.log('advanced: ', advanced)
  if (chevron.classList.contains("hero-chevron-down")) {
    chevron.classList.remove("hero-chevron-down")
    chevron.classList.add("hero-chevron-right")
    text.innerHTML = "Show Advanced"
    advanced.classList.add("hidden")
  } else {
    chevron.classList.remove("hero-chevron-right")
    chevron.classList.add("hero-chevron-down")
    text.innerHTML = "Hide Advanced"
    advanced.classList.remove("hidden")
  }
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
