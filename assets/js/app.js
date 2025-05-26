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
import tippy from "tippy.js";
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
  postgres: {
    tooltip: `
    <p class="mb-2">
    Ash & PostgreSQL, a match made in heaven.
    </p>
    <p>
    Just Ash and a database is a great place to start if you're
    not sure what you're building or just want to play around.
    We suggest that you add Phoenix if you are building an API
    or a web app.
    </p>
    `,
    features: ["postgres"],
  },
  live_view: {
    tooltip: `
    <p class="mb-2">
    Full stack Elixir!
    </p>
    <p>
    Perfect for the Elixir maximalist.
    </p>
    `,
    features: [
      "phoenix",
      "postgres",
      "magic_link_auth",
      "admin",
      "live_debugger",
    ],
  },
  graphql: {
    features: ["phoenix", "graphql", "postgres", "admin"],
    tooltip: `
    <p class="mb-2">
    A GraphQL API, a database and a dream.
    </p>
    <p>
    All the power of GraphQL, none of the boilerplate.
    </p>
    `,
  },
  json_api: {
    features: ["phoenix", "json_api", "postgres", "admin"],
    tooltip: `
    <p class="mb-2">
    JSON:API. Simple, battle-tested, effective.
    </p>
    <p>
    Create a simple yet elegant REST API, complete with an Open API spec!
    </p>
    `,
  },
};

const features = {
  phoenix: {
    adds: ["ash_phoenix"],
    links: [{ link: "https://phoenixframework.org", name: "Phoenix" }],
    order: 0,
    tooltip: `
    <p class="mb-2">
    Ash works seamlessly with Phoenix.
    </p>
    <p>
    Phoenix is your web layer, Ash is your application layer.
    </p>
    `,
  },
  graphql: {
    requires: ["phoenix"],
    adds: ["ash_graphql"],
    order: 1,
    links: [{ link: "https://hexdocs.pm/ash_graphql", name: "AshGraphql" }],
    tooltip: `
    <p class="mb-2">
    Create a powerful and flexible GraphQL API directly from your resources.
    </p>
    <p>
    Built on top of the excellent library Absinthe.
    No need for writing data loaders, resolvers or middleware!
    </p>
    `,
  },
  json_api: {
    requires: ["phoenix"],
    adds: ["ash_json_api"],
    order: 3,
    links: [{ link: "https://hexdocs.pm/ash_json_api", name: "AshJsonApi" }],
    tooltip: `
    <p class="mb-2">
    Easily create a spec-compliant JSON:API, directly from your resources.
    </p>
    <p>
    Generates an OpenAPI specification automatically, allowing easy integration with all kinds of tools and services.
    </p>
    `,
  },
  postgres: {
    adds: ["ash_postgres"],
    links: [{ link: "https://hexdocs.pm/ash_postgres", name: "AshPostgres" }],
    order: 4,
    tooltip: `
    <p class="mb-2">
    PostgreSQL
    </p>
    <p>
    The swiss army knife of databases. Versatile, powerful, and battle-tested.
    </p>
    `,
  },
  sqlite: {
    adds: ["ash_sqlite"],
    links: [{ link: "https://hexdocs.pm/ash_sqlite", name: "AshSqlite" }],
    order: 5,
    tooltip: `
    <p class="mb-2">
    SQLite
    </p>
    <p>
    Small, fast, and reliable. Perfect for lightweight apps or getting started quickly.
    </p>
    `,
  },
  password_auth: {
    requires: ["phoenix"],
    adds: ["ash_authentication", "ash_authentication_phoenix"],
    links: [
      {
        link: "https://hexdocs.pm/ash_authentication",
        name: "AshAuthentication",
      },
    ],
    order: 6,
    args: ["--auth-strategy password"],
    tooltip: `
    <p class="mb-2">
    Allow users to log in with email & password.
    </p>
    <p>
    Ships with email confirmation, password resets, and registration out of the box!
    </p>
    `,
  },
  magic_link_auth: {
    requires: ["phoenix"],
    adds: ["ash_authentication", "ash_authentication_phoenix"],
    order: 7,
    links: [
      {
        link: "https://hexdocs.pm/ash_authentication",
        name: "AshAuthentication",
      },
    ],
    args: ["--auth-strategy magic_link"],
    tooltip: `
    <p class="mb-2">
    Send users a link in their email to sign in and register.
    </p>
    <p>
    Who needs the complexity of emails & passwords? Keep it simple with magic links.
    </p>
    `,
  },
  api_key_auth: {
    requires: ["phoenix"],
    adds: ["ash_authentication"],
    order: 7.5,
    links: [
      {
        link: "https://hexdocs.pm/ash_authentication",
        name: "AshAuthentication",
      },
    ],
    args: ["--auth-strategy api_key"],
    tooltip: `
    <p class="mb-2">
    Generate and authenticate with API keys.
    </p>
    <p>
    Built for compliance with secret scanning tools, using industry best practice for
    generating and verifying API keys.
    </p>
    `,
  },
  oauth: {
    requires: ["phoenix"],
    adds: ["ash_authentication", "ash_authentication_phoenix"],
    order: 8,
    links: [
      {
        link: "https://hexdocs.pm/ash_authentication",
        name: "AshAuthentication",
      },
    ],
    requiresSetup: {
      name: "OAuth",
      href: "https://hexdocs.pm/ash_authentication",
    },
    tooltip: `
    <p class="mb-2">
    Sign in using an external service.
    </p>
    <p>
    Supports any OAuth2 provider with premade configurations for Apple, Google, Github, Auth0, Oidc, and Slack.
    </p>
    `,
  },
  money: {
    adds: ["ash_money"],
    order: 999,
    links: [{ link: "https://hexdocs.pm/ash_money", name: "AshMoney" }],
    tooltip: `
    <p class="mb-2">
    A data type for representing money $$$$.
    </p>
    <p>
    Ships with a postgres datatype, and operator and function definitions!
    </p>
    `,
  },
  csv: {
    adds: ["ash_csv"],
    links: [{ link: "https://hexdocs.pm/ash_csv", name: "AshCSV" }],
    order: 9,
    tooltip: `
    <p class="mb-2">
    Back resources with CSV files.
    </p>
    <p>
    Easily interact with CSV files in code, or turn a CSV file into an API in minutes.
    </p>
    `,
  },
  admin: {
    adds: ["ash_admin"],
    links: [{ link: "https://hexdocs.pm/ash_admin", name: "AshAdmin" }],
    order: 10,
    tooltip: `
    <p class="mb-2">
    A zero-config-necessary super admin UI.
    </p>
    <p>
    Call any resource action from an automatically generated web UI
    </p>
    `,
  },
  oban: {
    adds: ["ash_oban", "oban_web"],
    links: [{ link: "https://hexdocs.pm/ash_oban", name: "AshOban" }],
    order: 11,
    tooltip: `
    <p class="mb-2">
    Oban is a background job system backed by your own SQL database packed with enterprise grade features, real-time monitoring with Oban Web, and complex workflow management with Oban Pro.
    </p>
    <p class="mb-2">
    Configure triggers directly in your resources or write fully custom Oban jobs.
    </p>
    `,
  },
  state_machine: {
    adds: ["ash_state_machine"],
    links: [
      { link: "https://hexdocs.pm/ash_state_machine", name: "AshStateMachine" },
    ],
    order: 12,
    tooltip: `
    <p class="mb-2">
    Model complex workflows backed by your resource's persistence and actions.
    </p>
    <p>
    You can even generate fancy mermaid flow charts!
    </p>
    `,
  },
  ash_events: {
    adds: ["ash_events"],
    links: [{ link: "https://hexdocs.pm/ash_events", name: "AshEvents" }],
    order: 12.5,
    tooltip: `
    <p class="mb-2">
    Tracks and persists events when actions are performed on your resources, providing a complete audit trail and event replay.
    </p>
    <p>
    A declarative hybrid approach to event sourcing.
    </p>
    `,
  },
  double_entry: {
    requires: ["money"],
    adds: ["ash_double_entry"],
    order: 13,
    links: [
      { link: "https://hexdocs.pm/ash_double_entry", name: "AshDoubleEntry" },
    ],
    tooltip: `
    <p class="mb-2">
    Moving money around? Need to track financial data?
    </p>
    <p>
    Provides a data model for double entry accounting that can be extended to fit your own needs.
    </p>
    `,
  },
  archival: {
    adds: ["ash_archival"],
    order: 14,
    links: [{ link: "https://hexdocs.pm/ash_archival", name: "AshArchival" }],
    tooltip: `
    <p class="mb-2">
    A lightweight extension to ensure that data is only ever soft deleted.
    </p>
    <p>
    One line of code is all it takes to ensure that it is impossible to delete records.
    </p>
    `,
  },
  live_debugger: {
    adds: ["live_debugger"],
    requires: ["phoenix"],
    order: 15,
    links: [
      {
        link: "https://hexdocs.pm/live_debugger/",
        name: "Live Debugger",
      },
    ],
    tooltip: `
    <p class="mb-2">
    A tool for debugging LiveView applications in development.
    </p>
    <p>
    Optimizes your development by offering detailed component tree views, assigns inspection, and callback execution tracing.
    </p>
    `,
  },
  mishka: {
    adds: ["mishka_chelekom"],
    order: 16,
    links: [{ link: "https://mishka.tools/chelekom", name: "Mishka Chelekom" }],
    tooltip: `
    <p class="mb-2">
    Mishka Chelekom is a library offering various templates for components in Phoenix and Phoenix LiveView.
    </p>
    <p>
    No installation or dependencies needed — everything is configured directly into your project by the CLI generator.
    </p>
    `,
  },
  paper_trail: {
    adds: ["ash_paper_trail"],
    order: 17,
    links: [
      { link: "https://hexdocs.pm/ash_paper_trail", name: "AshPaperTrail" },
    ],
    tooltip: `
    <p class="mb-2">
    Automatically track all changes to your resources. Track who did what and when.
    </p>
    <p>
    Track just the changed values, the entire new state, or even a deep diff of changes.
    </p>
    `,
  },
  cloak: {
    adds: ["cloak", "ash_cloak"],
    links: [{ link: "https://hexdocs.pm/ash_cloak", name: "AshCloak" }],
    order: 18,
    tooltip: `
    <p class="mb-2">
    Easily encrypt and decrypt your attributes.
    </p>
    <p>
    You can even hook into decryption to track who is decrypting what and when!
    </p>
    `,
  },
  appsignal: {
    adds: ["appsignal", "ash_appsignal"],
    requiresSetup: {
      name: "AppSignal",
      href: "https://blog.appsignal.com/2023/02/28/an-introduction-to-test-factories-and-fixtures-for-elixir.html",
    },
    order: 19,
    linkName: "AppSignal",
    link: "https://hexdocs.pm/ash_appsignal",
    tooltip: `
    <p class="mb-2">
    Track errors and monitor your application with appsignal.
    </p>
    <p class="mb-2">
    Appsignal is a great way to get started with monitoring! Be sure to visit their website for setup instructions.
    </p>
    <p>
    Installer coming soon! Can be manually installed.
    </p>
    `,
  },
  opentelemetry: {
    adds: ["opentelemetry", "opentelemetry_ash"],
    requiresSetup: {
      name: "OpenTelemetry",
      href: "https://blog.appsignal.com/2023/02/28/an-introduction-to-test-factories-and-fixtures-for-elixir.html",
    },
    order: 20,
    links: [
      {
        link: "https://hexdocs.pm/opentelemetry_ash",
        name: "OpenTelemetryAsh",
      },
    ],
    tooltip: `
    <p class="mb-2">
    High-quality, ubiquitous, and portable telemetry to enable effective observability.
    </p>
    <p>
    OpenTelemetry is the state of the art observability system. Leverage first-class integration libraries for all
    your favorite Elixir libraries, including Ash!
    </p>
    <p class="mb-2">
    Installer coming soon! Can be manually installed.
    </p>
    `,
  },
  tidewave: {
    adds: ["tidewave"],
    order: 16,
    links: [{ link: "https://tidewave.ai", name: "Tidewave" }],
    tooltip: `
    <p class="mb-2">
    Speed up development with AI assistants that understand your web application, how it runs, and what it delivers.
    </p>
    <p>
    Tidewave is an MCP server, served by your application, that gives your agentic development workflow super powers.
    </p>
    `,
  },
  ash_ai: {
    adds: ["ash_ai"],
    order: 17,
    links: [{ link: "https://hexdocs.pm/ash_ai", name: "Ash AI" }],
    tooltip: `
    <p class="mb-2">
    First class support for a wide array of LLM tools.
    </p>
    <p>
    Structured outputs, production and development MCP servers, agentic tool calling, a pre-built chat interface and more.
    </p>
    `,
  },
};

let addingToApp = false;

window.addingToApp = function () {
  if (addingToApp) {
    addingToApp = false;

    document.getElementById("feature-phoenix").classList.remove("hidden");
    document.getElementById("quickstart-live_view").classList.remove("hidden");
    document.getElementById("already-have-an-app-button").innerHTML =
      "Already have an app?";
  } else {
    addingToApp = true;

    const feature = document.getElementById("feature-phoenix-active");
    if (!feature.classList.contains("hidden")) {
      feature.click();
    }
    document.getElementById("feature-phoenix").classList.add("hidden");
    document.getElementById("quickstart-live_view").classList.add("hidden");
    document.getElementById("already-have-an-app-button").innerHTML =
      "Creating a new app?";
  }

  setUrl();
};

for (var quickstart of Object.keys(quickstarts)) {
  const tooltip = quickstarts[quickstart].tooltip;
  if (tooltip) {
    addTooltip(`#quickstart-${quickstart}`, tooltip);
  }
}

for (var feature of Object.keys(features)) {
  const tooltip = features[feature].tooltip;

  if (tooltip) {
    addTooltip(`#feature-${feature}`, tooltip);
  }
}

function addTooltip(id, content) {
  const div = document.createElement("div");
  div.classList.add(
    "rounded-lg",
    "py-2",
    "px-4",
    "bg-black",
    "border",
    "border-primary-dark-500/40",
    "shadow-lg",
    "shadow-slate-950/80",
    "text-center",
  );
  div.innerHTML = content;
  const boundary = document.getElementById("#installer-bounds");
  tippy(id, {
    content: div,
    hideOnClick: false,
    animation: false,
    allowHTML: true,
    delay: 0,
    popperOptions: {
      modifiers: [
        {
          name: "flip",
          options: {
            padding: {
              top: 64,
            },
          },
        },
      ],
    },
  });
}

let appNameComponent = document.getElementById("app-name");

let appName = (appName || {}).value;

if (appNameComponent) {
  document.addEventListener("DOMContentLoaded", function () {
    document.getElementById("quickstart-live_view-inactive").click();
  });
}

function setUrl() {
  var button = document.getElementById("copy-url-button");
  var icon = document.getElementById("copy-url-button-icon");
  var text = document.getElementById("copy-url-button-text");

  text.innerHTML = "Copy";
  icon.classList.remove("hero-check");
  icon.classList.add("hero-clipboard");
  button.classList.remove("was-clicked");

  let args = [];
  let packages = ["ash"];
  let disabled = [];
  let setups = [];
  let links = [];
  for (var feature of Object.keys(features).sort((a, b) => {
    const orderA = features[a].order || 0;
    const orderB = features[b].order || 0;
    return orderA - orderB;
  })) {
    const config = features[feature];
    if (config.checked) {
      (config.requires || []).forEach((requirement) => {
        const requiredConfig = features[requirement];
        packages.push(...requiredConfig.adds);
        args.push(...(requiredConfig.args || []));

        if (requiredConfig.requiresSetup) {
          setups.push(
            `<a target="_blank" class="link" href="${requiredConfig.requiresSetup.href}">${requiredConfig.requiresSetup.name}</a>`,
          );
        }

        requiredConfig.links.forEach((link) => {
          links.push(
            `<a target="_blank" class="link" href="${link.link}">${link.name}</a>`,
          );
        });

        const activeBox = document.getElementById(
          `feature-${requirement}-active`,
        );
        const inactiveBox = document.getElementById(
          `feature-${requirement}-inactive`,
        );

        activeBox.classList.remove("hidden");
        inactiveBox.classList.add("hidden");

        activeBox.classList.add("opacity-70", "cursor-not-allowed");
        activeBox.classList.remove("cursor-pointer");

        features[requirement].checked = true;
        disabled.push(requirement);

        features[feature].checked = true;
      });

      packages.push(...config.adds);
      args.push(...(config.args || []));

      config.links.forEach((link) => {
        links.push(
          `<a target="_blank" class="link" href="${link.link}">${link.name}</a>`,
        );
      });

      if (config.requiresSetup) {
        setups.push(
          `<a target="_blank" class="link" href="${config.requiresSetup.href}">${config.requiresSetup.name}</a>`,
        );
      }
    }
  }

  [...document.querySelectorAll(".active-feature")].forEach((el) => {
    if (!disabled.includes(el.dataset.name)) {
      el.classList.remove("opacity-70", "cursor-not-allowed");
    }
  });

  packages = [...new Set(packages)];
  args = [...new Set(args)];
  setups = [...new Set(setups)];
  links = [...new Set(links)];

  let base;
  if (location.hostname === "localhost" || location.hostname === "127.0.0.1") {
    base = "localhost:4000/install";
  } else {
    base = "https://ash-hq.org/install";
  }

  const appNameSafe = appNameComponent.value
    .replace(/[^a-zA-Z0-9\s_-]/g, "")
    .replace(/[\s-_]+/g, "_")
    .replace(/^_+|_+$/g, "")
    .replace(/^(\d)/, "app_$1")
    .toLowerCase();

  let installArg;
  if (features.phoenix.checked) {
    installArg = "?install=phoenix";
    if (features.postgres.checked) {
    } else if (features.sqlite.checked) {
      installArg += `&with_args=--database%20sqlite3`;
    } else {
      installArg += `&with_args=--no-ecto`;
    }
  }

  const argsString = args.join(" ");
  let firstLine = `sh <(curl '${base}/${appNameSafe}${installArg || ""}')`;
  let limit;

  let code = firstLine;

  if (addingToApp) {
    code = "mix igniter.install ";
    packages.unshift("ash");
  } else {
    if (packages.length !== 0) {
      packages.unshift("&& mix igniter.install");
    }

    packages.unshift(`&& cd ${appNameSafe}`);
  }

  limit = Math.max(firstLine.length - 2, 45);

  args.forEach((arg) => {
    packages.push(arg);
  });

  if (args.length != 0 || packages.length != 0) {
    packages.push("--yes");
  }

  if (features.postgres.checked || features.sqlite.checked) {
    packages.push("&& mix ash.setup");
  }

  let currentLine = code;
  code = "";
  for (let i = 0; i < packages.length; i++) {
    if ((currentLine + packages[i]).length > limit) {
      code =
        code +
        `
    ${currentLine.trim()} \\`;
      currentLine = "";
    }
    currentLine += packages[i] + " ";
  }
  if (currentLine.trim().length > 0) {
    code =
      code +
      `
    ${currentLine.trim()}`;
  }

  const manualSetupBox = document.getElementById("manual-setup-box");

  if (setups.length === 0) {
    manualSetupBox.classList.add("hidden");
  } else {
    manualSetupBox.classList.remove("hidden");
    const manualSetupLinks = document.getElementById("manual-setup-links");
    manualSetupLinks.innerHTML = setups.join("");
  }

  const readMoreBox = document.getElementById("read-more-box");

  if (links.length === 0) {
    readMoreBox.classList.add("hidden");
  } else {
    readMoreBox.classList.remove("hidden");
    const readMoreLinks = document.getElementById("read-more-links");
    readMoreLinks.innerHTML = links.join("");
  }

  const el = document.getElementById("selected-features");
  el.innerHTML = code.trim();
}

window.cantDecide = function () {
  document.getElementById("cant-decide").classList.add("hidden");

  [...document.querySelectorAll(".feature-category")].forEach((el) => {
    el.classList.add("hidden");
  });

  [...document.querySelectorAll(".active-quickstart")].forEach((el) => {
    if (!el.classList.contains("hidden")) {
      el.click();
    }
  });

  document.getElementById("asterisk-warning").classList.add("hidden");
  document.getElementById("quickstart-live_view-inactive").click();

  document.getElementById("show-options").classList.remove("hidden");
  document.getElementById("dont-worry").classList.remove("hidden");
};

window.showAll = function () {
  document.getElementById("cant-decide").classList.remove("hidden");

  [...document.querySelectorAll(".feature-category")].forEach((el) => {
    el.classList.remove("hidden");
  });

  document.getElementById("show-options").classList.add("hidden");
  document.getElementById("dont-worry").classList.add("hidden");
  document.getElementById("asterisk-warning").classList.remove("hidden");
};

window.clickOnPreset = function (name) {
  var element = document.getElementById("quickstart-" + name + "-inactive");
  if (element && element.style.display !== "none") {
    element.click();
  }
};

window.featureClicked = function (el, toggleTo, checked) {
  const name = el.dataset.name;
  features[name].checked = checked;
  el.classList.add("hidden");
  document.getElementById(toggleTo).classList.remove("hidden");

  setUrl();
};

window.quickStartClicked = function (el, toggleTo, checked) {
  [...document.querySelectorAll(".active-quickstart")].forEach((el) => {
    el.classList.add("hidden");
  });

  [...document.querySelectorAll(".inactive-quickstart")].forEach((el) => {
    el.classList.remove("hidden");
  });

  [...document.querySelectorAll(".active-feature")].forEach((el) => {
    el.classList.add("hidden");
  });

  [...document.querySelectorAll(".inactive-feature")].forEach((el) => {
    el.classList.remove("hidden");
  });

  el.classList.add("hidden");
  document.getElementById(toggleTo).classList.remove("hidden");

  for (var feature of Object.keys(features)) {
    features[feature].checked = false;
  }

  const toClick = quickstarts[el.dataset.name].features;

  if (checked) {
    toClick.forEach((name) => {
      document.getElementById(`feature-${name}-inactive`).click();
    });
  }

  setUrl();
};

window.appNameChanged = function (el) {
  appName = el.value;

  setUrl();
};

window.showAdvancedFeatures = function () {
  const chevron = document.getElementById("advanced-chevron");
  const text = document.getElementById("advanced-text");
  const advanced = document.getElementById("advanced-features");
  if (chevron.classList.contains("rotate-90")) {
    chevron.classList.remove("rotate-90");
    text.innerHTML = "Show all";
    advanced.classList.add("hidden");
  } else {
    chevron.classList.add("rotate-90");
    text.innerHTML = "Hide";
    advanced.classList.remove("hidden");
  }
};

window.copyUrl = function (el) {
  // Get the text field
  var copyText = document.getElementById("selected-features").innerHTML;

  copyText = copyText
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&amp;/g, "&");

  navigator.clipboard.writeText(copyText);

  var button = document.getElementById("copy-url-button");
  var icon = document.getElementById("copy-url-button-icon");
  var text = document.getElementById("copy-url-button-text");

  text.innerHTML = "Copied";
  icon.classList.remove("hero-clipboard");
  icon.classList.add("hero-check");
  button.classList.add("was-clicked");
};

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.disableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
