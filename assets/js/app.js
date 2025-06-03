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
  beacon: {
    requires: ["phoenix"],
    adds: ["beacon", "beacon_live_admin"],
    order: 1000,
    links: [
      { link: "https://hexdocs.pm/beacon", name: "Beacon" },
      {
        link: "https://hexdocs.pm/beacon_live_admin",
        name: "Beacon Live Admin",
      },
    ],
    args: ["--beacon.site cms", "--beacon-live-admin.path /cms/admin"],
    tooltip: `
    <p class="mb-2">
    Open-source Content Management System (CMS) built with Phoenix LiveView.
    </p>
    <p>
    Faster render times to boost SEO performance, even for the most content-heavy pages.
    </p>
    <p class="text-red-400">
    Does not support windows.
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
    document.getElementById("igniter-instruction").classList.add("hidden");
    const button = document.getElementById("already-have-an-app-button");
    button.innerHTML = `
      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4"></path>
      </svg>
      Already have an app?`;
  } else {
    addingToApp = true;

    const feature = document.getElementById("feature-phoenix-active");
    if (!feature.classList.contains("hidden")) {
      feature.click();
    }
    document.getElementById("feature-phoenix").classList.add("hidden");
    document.getElementById("quickstart-live_view").classList.add("hidden");
    document.getElementById("igniter-instruction").classList.remove("hidden");
    const button = document.getElementById("already-have-an-app-button");
    button.innerHTML = `
      <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"></path>
      </svg>
      Creating a new app?`;
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
  const advancedFeaturesVisible = !document
    .getElementById("advanced-features")
    .classList.contains("hidden");

  if (links.length === 0) {
    readMoreBox.classList.add("hidden");
  } else if (advancedFeaturesVisible) {
    readMoreBox.classList.remove("hidden");
    const readMoreLinks = document.getElementById("read-more-links");
    readMoreLinks.innerHTML = links.join("");
  } else {
    readMoreBox.classList.add("hidden");
  }

  const el = document.getElementById("selected-features");
  el.innerHTML = code.trim();
}

window.showAdvanced = function () {
  document.getElementById("show-advanced").classList.add("hidden");
  document.getElementById("hide-advanced").classList.remove("hidden");
  document.getElementById("advanced-features").classList.remove("hidden");
  document.getElementById("asterisk-warning").classList.remove("hidden");
  document.getElementById("read-more-box").classList.remove("hidden");
};

window.hideAdvanced = function () {
  document.getElementById("show-advanced").classList.remove("hidden");
  document.getElementById("hide-advanced").classList.add("hidden");
  document.getElementById("advanced-features").classList.add("hidden");
  document.getElementById("asterisk-warning").classList.add("hidden");
  document.getElementById("read-more-box").classList.add("hidden");
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

// Ash Interactive Animation
const AshAnimation = {
  // Animation stages with code snippets
  stages: [
    {
      name: "Resources & Actions",
      module: "MyApp.Blog.Post",
      description:
        "Resources & Actions are the core abstraction in Ash. Actions are fully typed and introspectable (your application can examine them at runtime). This means extensions can automatically understand and build on top of them.",
      code: `
  actions do
    action :reading_time, :integer do
      argument :content, :string,
        allow_nil?: false

      run fn input, _ ->
        words =
          input.arguments.content
          |> String.split()
          |> length()

        {:ok, div(words, 200) + 1}
      end
    end
  end
end`,
      visualizer: () => AshAnimation.createFunctionInterface(),
    },
    {
      name: "Persistence",
      module: "MyApp.Blog.Post",
      description:
        "Now let's add state to support persistent storage, while keeping our existing behavior. Your resource now combines behavior and state. The original action still works exactly the same, plus you can create and persist posts.",
      code: `
    data_layer: AshPostgres.DataLayer

  postgres do
    table "posts"
    repo MyApp.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string,
      allow_nil?: false
    attribute :content, :string
    attribute :state, :atom,
      constraints: [
        one_of: [:draft, :published]
      ]

    timestamps()
  end
  # ...
end`,
      visualizer: () => AshAnimation.createPostgresTable(),
    },
    {
      name: "GraphQL",
      module: "MyApp.Blog.Post",
      description:
        "Add a full GraphQL API with minimal configuration. The extension automatically understands your existing actions and generates queries, mutations, and types.",
      code: `
    extensions: [AshGraphql.Resource]

  graphql do
    type :post

    queries do
      get :post, :read
      list :posts, :read
    end

    mutations do
      create :create_post, :create
      update :update_post, :update
      destroy :delete_post, :destroy
    end
  end
  # ...
end`,
      visualizer: () => AshAnimation.createGraphQLPanel(),
    },
    {
      name: "JSON:API",
      module: "MyApp.Blog.Post",
      description:
        "Add a REST JSON:API alongside your GraphQL API. All API extensions work on top of your resources and actions. Ash makes it trivial to expose your domain through multiple API standards, letting clients choose the interface that works best for them.",
      code: `
    extensions: [
      AshGraphql.Resource,
      AshJsonApi.Resource
    ]

  json_api do
    type "post"

    routes do
      base "/posts"
      get :read
      index :read
      post :create
      patch :update
    end
  end
  # ...
end`,
      visualizer: () => AshAnimation.createJsonApiPanel(),
    },
    {
      name: "Encryption",
      module: "MyApp.Blog.Post",
      description:
        "Add encryption at rest with our Cloak integration. Your post content is now automatically encrypted when stored and decrypted when read, with no changes to your existing API or business logic. The encryption is completely transparent to your application code.",
      code: `
    extensions: [
      AshGraphql.Resource,
      AshJsonApi.Resource,
      AshCloak.Resource
    ]

  cloak do
    vault MyApp.Vault
    # Automatically encrypt content
    attributes [:content]
  end
  # ...
end`,
      visualizer: () => AshAnimation.createEncryptionFlow(),
    },
    {
      name: "AI Tools",
      module: "MyApp.Blog.Post",
      description:
        "Add AI-powered actions and expose your domain as tools for LLMs. Ash AI lets you create prompt-backed actions that delegate to AI models, and exposes your existing actions as tools that AI agents can use. Perfect for building AI-powered features or MCP (Model Context Protocol) servers.",
      code: `
    extensions: [
      #...,
      AshAi
    ]

  actions do
    # AI-powered action
    action :analyze_sentiment, :atom do
      constraints [
        one_of: [:positive, :negative]
      ]

      argument :content, :string,
        allow_nil?: false

      run prompt(
        ChatOpenAI.new!(
          %{model: "gpt-4o"}
        )
      )
    end
  end
  #...
end`,
      visualizer: () => AshAnimation.createAiToolsPanel(),
    },
    {
      name: "State Machine",
      module: "MyApp.Blog.Post",
      description:
        "Add a proper state machine to model valid states and transitions. Your posts now have declarative state validations and transitions. Notice how each extension builds upon the previous ones without requiring changes to existing functionality.",
      code: `
    extensions: [
      # ...
      AshStateMachine
    ]

  state_machine do
    initial_states [:draft]

    transitions do
      transition :publish,
        from: :draft,
        to: :published

      transition :unpublish,
        from: :published,
        to: :draft
    end
  end
  # ...
end`,
      visualizer: () => AshAnimation.createStateMachine(),
    },
    {
      name: "Authentication",
      module: "MyApp.Accounts.User",
      description:
        "Add complete user authentication with password and OAuth strategies. AshAuthentication provides built-in support for password authentication, OAuth providers (GitHub, Google, etc.), magic links, and more.",
      code: `
    extensions: [AshAuthentication]

  authentication do
    strategies do
      password do
        # ...
      end

      magic_link do
        # ...
      end
    end
  end
  # ...
end`,
      visualizer: () => AshAnimation.createAuthenticationPanel(),
    },
    {
      name: "Background Jobs",
      module: "MyApp.Blog.Post",
      description:
        "Add background job processing with AshOban. Define triggers that run periodically for records matching conditions, and scheduled actions that run on cron schedules. Perfect for notifications, data processing, and maintenance tasks.",
      code: `
    extensions: [
      # ...
      AshOban
    ]

  oban do
    triggers do
      trigger :publish do
        where expr(state == :pending)
        scheduler_cron "@hourly"
      end
    end
    scheduled_actions do
      schedule :cleanup_old_drafts,
        "@daily"
    end
  end
  # ...
end`,
      visualizer: () => AshAnimation.createObanPanel(),
    },
  ],

  // State
  currentStage: 0,
  typingInterval: null,
  animationActive: false,
  observer: null,
  currentTypeCallback: null,
  pendingTypeCode: "",
  isPlaying: true,
  playInterval: null,
  hasBeenInitiated: false,
  pendingTimeouts: [],
  currentAnimationId: 0,
  prefersReducedMotion: false,
  initialSetupDone: false,
  loadedFromHash: false,

  // Mobile stage navigation
  mobileCurrentStage: 0,
  mobileStageCount: 9,

  // Initialize the animation
  init() {
    // Detect user's motion preference
    this.prefersReducedMotion =
      window.matchMedia &&
      window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    const container = document.getElementById("ash-animation");
    if (!container) {
      return;
    }

    // Add event listeners for navigation buttons
    const prevBtn = document.getElementById("prev-stage");
    const nextBtn = document.getElementById("next-stage");
    const playPauseBtn = document.getElementById("play-pause");

    if (prevBtn) {
      prevBtn.addEventListener("click", () => this.previousStage());
    }
    if (nextBtn) {
      nextBtn.addEventListener("click", () => this.nextStage());
    }
    if (playPauseBtn) {
      playPauseBtn.addEventListener("click", () => this.togglePlayPause());
    }

    const linkBtn = document.getElementById("link-stage");
    if (linkBtn) {
      linkBtn.addEventListener("click", () => this.copyStageLink());
    }

    // Set up intersection observer to start animation when visible
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (
            entry.isIntersecting &&
            entry.intersectionRatio > 0.5 &&
            !this.hasBeenInitiated
          ) {
            this.hasBeenInitiated = true;
            this.start();
          }
        });
      },
      { threshold: 0.5 },
    );

    this.observer.observe(container);

    // Check URL hash for specific stage first
    const hasHash = this.handleUrlHash();

    // Only show initial stage if no hash was processed
    if (!hasHash) {
      this.updateDescription(0);
      this.addVisualization(this.stages[0].visualizer(), 0);
      this.updateProgressDots();
    }

    this.initialSetupDone = true;

    // Check immediately if element is already visible
    const rect = container.getBoundingClientRect();
    const isInView = rect.top < window.innerHeight && rect.bottom > 0;

    if (isInView && !this.hasBeenInitiated && this.initialSetupDone) {
      this.hasBeenInitiated = true;
      this.start();
    }

    // Set initial play/pause button state based on reduced motion preference
    const playIcon = document.getElementById("play-icon");
    const pauseIcon = document.getElementById("pause-icon");
    if (this.prefersReducedMotion) {
      // Start with play button visible (paused state)
      if (playIcon) playIcon.classList.remove("hidden");
      if (pauseIcon) pauseIcon.classList.add("hidden");
    } else {
      // Normal behavior - start playing
      if (playIcon) playIcon.classList.add("hidden");
      if (pauseIcon) pauseIcon.classList.remove("hidden");
    }

    // Initialize mobile stage navigation
    this.initMobileStages();
  },

  // Initialize mobile stage navigation
  initMobileStages() {
    const mobileContainer = document.getElementById("mobile-stages");
    if (!mobileContainer) return;

    const prevBtn = document.getElementById("mobile-prev");
    const nextBtn = document.getElementById("mobile-next");
    const track = document.getElementById("mobile-stage-track");

    if (prevBtn) {
      prevBtn.addEventListener("click", () => this.mobilePrevStage());
    }
    if (nextBtn) {
      nextBtn.addEventListener("click", () => this.mobileNextStage());
    }

    // Touch/swipe support
    if (track) {
      let startX = 0;
      let currentX = 0;
      let isDragging = false;

      track.addEventListener(
        "touchstart",
        (e) => {
          startX = e.touches[0].clientX;
          isDragging = true;
        },
        { passive: true },
      );

      track.addEventListener(
        "touchmove",
        (e) => {
          if (!isDragging) return;
          currentX = e.touches[0].clientX;
        },
        { passive: true },
      );

      track.addEventListener(
        "touchend",
        () => {
          if (!isDragging) return;
          isDragging = false;

          const diff = startX - currentX;
          if (Math.abs(diff) > 50) {
            // Minimum swipe distance
            if (diff > 0) {
              this.mobileNextStage();
            } else {
              this.mobilePrevStage();
            }
          }
        },
        { passive: true },
      );
    }

    // Check if there's a hash in the URL and set mobile stage accordingly
    const hash = window.location.hash;
    if (hash.startsWith("#ash-animation-")) {
      const slug = hash.replace("#ash-animation-", "");
      const stageIndex = this.getStageFromSlug(slug);
      if (stageIndex >= 0 && stageIndex < this.stages.length) {
        this.mobileCurrentStage = stageIndex;
      }
    }

    this.updateMobileStage();

    // Initialize mobile stage content on load
    this.updateMobileStageContent();
  },

  // Navigate to previous mobile stage
  mobilePrevStage() {
    if (this.mobileCurrentStage > 0) {
      this.mobileCurrentStage--;
      this.updateMobileStage();
      this.updateMobileUrlHash();
    }
  },

  // Navigate to next mobile stage
  mobileNextStage() {
    if (this.mobileCurrentStage < this.mobileStageCount - 1) {
      this.mobileCurrentStage++;
      this.updateMobileStage();
      this.updateMobileUrlHash();
    }
  },

  // Update URL hash for mobile navigation
  updateMobileUrlHash() {
    const slug = this.getStageSlug(this.mobileCurrentStage);
    const newHash = `#ash-animation-${slug}`;
    if (window.location.hash !== newHash) {
      history.replaceState(null, null, newHash);
    }
  },

  // Update mobile stage display
  updateMobileStage() {
    const track = document.getElementById("mobile-stage-track");
    const prevBtn = document.getElementById("mobile-prev");
    const nextBtn = document.getElementById("mobile-next");

    if (track) {
      const translateX = -this.mobileCurrentStage * 100;
      track.style.transform = `translateX(${translateX}%)`;
    }

    // Update button states
    if (prevBtn) {
      prevBtn.disabled = this.mobileCurrentStage === 0;
    }
    if (nextBtn) {
      nextBtn.disabled = this.mobileCurrentStage === this.mobileStageCount - 1;
    }

    // Update dots
    const dots = document.querySelectorAll(".mobile-dot");
    dots.forEach((dot, index) => {
      if (index === this.mobileCurrentStage) {
        dot.classList.remove("bg-primary-dark-500/30");
        dot.classList.add("bg-primary-light-500");
      } else {
        dot.classList.remove("bg-primary-light-500");
        dot.classList.add("bg-primary-dark-500/30");
      }
    });

    // Update mobile stage content
    this.updateMobileStageContent();
  },

  // Update mobile stage content using the same stages data as desktop
  updateMobileStageContent() {
    const stageElement = document.querySelector(
      `[data-mobile-stage="${this.mobileCurrentStage}"]`,
    );
    if (!stageElement || !this.stages[this.mobileCurrentStage]) return;

    const stage = this.stages[this.mobileCurrentStage];

    // Update title
    const titleElement = stageElement.querySelector(".mobile-stage-title");
    if (titleElement) {
      titleElement.textContent = stage.name;
    }

    // Update description
    const descriptionElement = stageElement.querySelector(
      ".mobile-stage-description",
    );
    if (descriptionElement) {
      descriptionElement.textContent = stage.description;
    }

    // Update code display
    const codeElement = stageElement.querySelector(".mobile-code-display code");
    if (codeElement && stage.code) {
      codeElement.innerHTML = this.renderMobileCode(stage.code, stage.module);
    }

    // Update summary (extract from description or use existing)
    const summaryElement = stageElement.querySelector(".mobile-stage-summary");
    if (summaryElement) {
      // Keep existing summary content as it's stage-specific
    }
  },

  // Render code for mobile display using same syntax highlighting as desktop
  renderMobileCode(code, module) {
    // Prepare the full code with module wrapper like desktop version
    const fullCode = `defmodule ${module} do
  use Ash.Resource${code}`;

    // Parse and highlight the code
    const tokens = this.parseElixirTokens(fullCode);

    // Convert tokens to HTML
    return tokens
      .map((token) => {
        return `<span class="${token.className}">${this.escapeHtml(token.text)}</span>`;
      })
      .join("");
  },

  // Helper function to escape HTML
  escapeHtml(text) {
    const div = document.createElement("div");
    div.textContent = text;
    return div.innerHTML;
  },

  // Navigate to previous stage
  previousStage() {
    if (this.currentStage > 0) {
      this.pause();
      this.currentStage--;
      this.showStageManual(this.currentStage);
      this.updatePlayPauseButton(false);
    }
  },

  // Navigate to next stage
  nextStage() {
    if (this.currentStage < this.stages.length - 1) {
      this.pause();
      this.currentStage++;
      this.showStageManual(this.currentStage);
      this.updatePlayPauseButton(false);
    }
  },

  // Show stage for manual navigation (clears and rebuilds)
  showStageManual(stageIndex) {
    this.cancelPendingOperations();
    this.currentStage = stageIndex;
    this.updateNavigationButtons();
    this.updateProgressDots();
    this.updateDescription(stageIndex);

    const stage = this.stages[stageIndex];

    // Clear all visualizations
    this.clearAllVisualizations();

    // Handle layout for stage
    this.updateLayoutForStage(false);

    const codeDisplay = document.getElementById("code-display");

    // Set base content
    if (stageIndex === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  `;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>,`;
    }

    // Add stage-specific content
    const tokens = this.parseElixirTokens(stage.code);
    tokens.forEach((token) => {
      const span = document.createElement("span");
      span.className = token.className;
      span.textContent = token.text;
      codeDisplay.appendChild(span);
    });

    // Add summaries for previous stages
    for (let i = 0; i < stageIndex; i++) {
      const summaryContent = this.createSummaryForStage(i);
      this.addSummaryToGrid(summaryContent, i);
    }

    // Add current stage visualization
    this.addVisualization(this.stages[stageIndex].visualizer(), stageIndex);
  },

  // Show a specific stage for initial load
  showStage(stageIndex) {
    this.showStageProgressive(stageIndex);
  },

  showStageProgressive(stageIndex) {
    this.cancelPendingOperations();
    this.currentStage = stageIndex;
    this.updateNavigationButtons();
    this.updateProgressDots();
    this.updateDescription(stageIndex);

    const stage = this.stages[stageIndex];

    // Always clear and rebuild to ensure clean state
    this.clearAllVisualizations();

    // Handle layout for stage
    this.updateLayoutForStage(false);

    const codeDisplay = document.getElementById("code-display");

    // Set base content
    if (stageIndex === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  `;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>,`;
    }

    // Add stage-specific content without typing animation
    const tokens = this.parseElixirTokens(stage.code);
    tokens.forEach((token) => {
      const span = document.createElement("span");
      span.className = token.className;
      span.textContent = token.text;
      codeDisplay.appendChild(span);
    });

    // Add all stages as full visualizations first (including previous ones)
    for (let i = 0; i <= stageIndex; i++) {
      this.addVisualization(this.stages[i].visualizer(), i);
    }

    // Convert previous stages to summaries
    if (stageIndex > 0) {
      this.transitionPreviousStagesToSummary(stageIndex);
    }
  },

  // Build visualizations progressively showing accumulation
  buildProgressiveVisualizations(targetStage) {
    const animationId = this.currentAnimationId;

    // Add all summary stages immediately
    for (let i = 0; i < targetStage; i++) {
      const summaryContent = this.createSummaryForStage(i);
      this.addSummaryToGrid(summaryContent, i);
    }

    // Add current stage as full visualization with optional delay
    const delay = this.prefersReducedMotion ? 0 : 100;
    const timeoutId = setTimeout(() => {
      // Check if this animation is still current
      if (animationId !== this.currentAnimationId) {
        return;
      }

      this.addVisualization(this.stages[targetStage].visualizer(), targetStage);
    }, delay);

    this.pendingTimeouts.push(timeoutId);
  },

  // Add summary directly to grid
  addSummaryToGrid(summaryContent, stageIndex) {
    const panel = document.getElementById("visualization-panel");

    // Create or get summary grid
    let summaryGrid = document.getElementById("summary-grid");
    if (!summaryGrid) {
      summaryGrid = document.createElement("div");
      summaryGrid.id = "summary-grid";
      summaryGrid.className = "grid gap-4 mb-4";
      panel.appendChild(summaryGrid);
    }

    // Update grid columns
    const currentSummaries = summaryGrid.children.length;
    const cols = Math.min(currentSummaries + 1, 4);
    summaryGrid.className = `grid grid-cols-${cols} gap-4 mb-8`;

    // Create summary container
    const summaryContainer = document.createElement("div");
    summaryContainer.id = `stage-${stageIndex}`;
    summaryContainer.className =
      "stage-visualization stage-summary transition-all duration-300 ease-in-out";
    summaryContainer.innerHTML = summaryContent;

    // Add immediately (no animation for summary boxes)
    summaryGrid.appendChild(summaryContainer);
  },

  // Start the animation with typing
  start() {
    if (this.animationActive) return;

    // Don't auto-start if user prefers reduced motion, but show initial content
    if (this.prefersReducedMotion) {
      this.isPlaying = false;
      this.updatePlayPauseButton(false);
      this.showStageProgressive(0); // Show the first stage without animation
      return;
    }

    this.isPlaying = true;
    this.animationActive = true;
    this.animate();
  },

  // Main animation loop with typing
  animate() {
    if (!this.animationActive || this.loadedFromHash) return;

    const stage = this.stages[this.currentStage];

    // Handle layout for stage
    this.updateLayoutForStage(false);

    const codeDisplay = document.getElementById("code-display");

    // Reset to base content when starting new stage
    if (this.currentStage === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  <span id="typing-cursor" class="inline-block w-2 h-[1em] bg-primary-light-500 animate-pulse"></span>`;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">${stage.module}</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>,
<span id="typing-cursor" class="inline-block w-2 h-[1em] bg-primary-light-500 animate-pulse"></span>`;
    }

    this.updateProgressDots();

    // Clear all visualizations only when restarting (stage 0)
    if (this.currentStage === 0) {
      this.clearAllVisualizations();
      this.updateDescription(0);
      // Only add visualization if stage-0 doesn't already exist
      const existing = document.getElementById("stage-0");
      if (!existing) {
        this.addVisualization(stage.visualizer(), 0);
      }
    } else {
      // For non-first stages, always clear and add new content
      this.clearAllVisualizations();

      // Add summaries for previous stages
      for (let i = 0; i < this.currentStage; i++) {
        const summaryContent = this.createSummaryForStage(i);
        this.addSummaryToGrid(summaryContent, i);
      }

      // Update description and add new visualization with delay for non-first stages
      this.updateDescription(this.currentStage);
      const visualizationTimeoutId = setTimeout(() => {
        this.addVisualization(stage.visualizer(), this.currentStage);
      }, 200);
      this.pendingTimeouts.push(visualizationTimeoutId);
    }

    // Type the code (trim leading newline for stages 2+ to prevent extra blank line)
    const codeToType =
      this.currentStage >= 1 ? stage.code.replace(/^\n/, "") : stage.code;
    this.typeCode(codeToType, () => {
      // Hide cursor after typing
      const cursor = document.getElementById("typing-cursor");
      if (cursor) {
        cursor.style.display = "none";
      }

      // Wait before moving to next stage
      const nextStageTimeoutId = setTimeout(() => {
        this.currentStage = (this.currentStage + 1) % this.stages.length;

        // Update navigation buttons after stage change
        this.updateNavigationButtons();

        // Continue animation if active
        if (this.animationActive) {
          this.animate();
        }
      }, 4000);
      this.pendingTimeouts.push(nextStageTimeoutId);
    });
  },

  // Cancel all pending operations to prevent stage confusion
  cancelPendingOperations() {
    // Increment animation ID to invalidate any pending operations
    this.currentAnimationId++;

    // Clear all pending timeouts
    this.pendingTimeouts.forEach((timeoutId) => clearTimeout(timeoutId));
    this.pendingTimeouts = [];

    // Stop any ongoing typing animation
    if (this.typingInterval) {
      clearTimeout(this.typingInterval);
      this.typingInterval = null;
    }

    // Clear typing state
    this.currentTypeCallback = null;
    this.pendingTypeCode = "";
  },

  // Toggle autoplay
  togglePlayPause() {
    if (this.isPlaying) {
      // Complete current typing before pausing
      this.completeCurrentTyping();
      this.pause();
      this.updatePlayPauseButton(false);
    } else {
      this.isPlaying = true;
      this.animationActive = true;
      this.loadedFromHash = false;
      this.updatePlayPauseButton(true);
      this.animate();
    }
  },

  // Update play/pause button visual state
  updatePlayPauseButton(isPlaying) {
    const playIcon = document.getElementById("play-icon");
    const pauseIcon = document.getElementById("pause-icon");

    if (isPlaying) {
      if (playIcon) playIcon.classList.add("hidden");
      if (pauseIcon) pauseIcon.classList.remove("hidden");
    } else {
      if (playIcon) playIcon.classList.remove("hidden");
      if (pauseIcon) pauseIcon.classList.add("hidden");
    }
  },

  // Start autoplay
  play() {
    this.isPlaying = true;
    this.animationActive = true;
    this.animate();
  },

  // Stop autoplay
  pause() {
    this.isPlaying = false;
    this.animationActive = false;
    this.cancelPendingOperations();
  },

  // Update navigation button states
  updateNavigationButtons() {
    const prevBtn = document.getElementById("prev-stage");
    const nextBtn = document.getElementById("next-stage");

    if (prevBtn) {
      prevBtn.disabled = this.currentStage === 0;
    }
    if (nextBtn) {
      nextBtn.disabled = this.currentStage === this.stages.length - 1;
    }
  },

  // Type code character by character
  typeCode(code, callback) {
    const codeDisplay = document.getElementById("code-display");

    // Store callback and complete code (including current content) for potential completion
    this.currentTypeCallback = callback;

    // Get current content without the cursor to include in pending code
    const cursor = document.getElementById("typing-cursor");
    let currentContent = "";
    if (codeDisplay && cursor) {
      const tempDiv = codeDisplay.cloneNode(true);
      const tempCursor = tempDiv.querySelector("#typing-cursor");
      if (tempCursor) tempCursor.remove();
      currentContent = tempDiv.textContent || "";
    }

    this.pendingTypeCode = currentContent + code;

    // Check if elements exist
    if (!codeDisplay) {
      console.error("Code display element not found");
      callback();
      return;
    }

    // Parse the code into tokens first
    const tokens = this.parseElixirTokens(code);
    let tokenIndex = 0;
    let charInToken = 0;

    const type = () => {
      if (!this.animationActive) return;

      // Get cursor each time since it may be recreated
      const cursor = document.getElementById("typing-cursor");
      if (!cursor) {
        console.error("Cursor not found");
        callback();
        return;
      }

      if (tokenIndex < tokens.length) {
        const token = tokens[tokenIndex];

        if (charInToken === 0) {
          // Starting a new token, create the span
          const span = document.createElement("span");
          span.className = token.className;
          span.textContent = "";
          // Insert before cursor
          codeDisplay.insertBefore(span, cursor);
        }

        // Add one character to the current token
        const spans = codeDisplay.querySelectorAll("span:not(#typing-cursor)");
        const currentSpan = spans[spans.length - 1];
        if (currentSpan) {
          currentSpan.textContent += token.text[charInToken];
        }

        charInToken++;

        if (charInToken >= token.text.length) {
          // Move to next token
          tokenIndex++;
          charInToken = 0;
        }

        // Removed scrollIntoView to prevent interference with page scrolling

        // Variable typing speed
        const char = token.text[charInToken - 1];
        const delay = this.prefersReducedMotion
          ? 0
          : char === "\n"
            ? 150
            : char === " "
              ? 30
              : 40 + Math.random() * 20;
        this.typingInterval = setTimeout(type, delay);
      } else {
        this.currentTypeCallback = null;
        this.pendingTypeCode = "";
        callback();
      }
    };

    type();
  },

  // Complete current typing instantly
  completeCurrentTyping() {
    if (this.currentTypeCallback && this.pendingTypeCode) {
      // Clear any pending typing timeouts
      if (this.typingInterval) {
        clearTimeout(this.typingInterval);
        this.typingInterval = null;
      }

      const codeDisplay = document.getElementById("code-display");

      if (codeDisplay) {
        // Parse the complete code and replace everything
        const tokens = this.parseElixirTokens(this.pendingTypeCode);

        // Clear all content and rebuild with complete code
        codeDisplay.innerHTML = "";

        // Add all tokens instantly
        tokens.forEach((token) => {
          const span = document.createElement("span");
          span.className = token.className;
          span.textContent = token.text;
          codeDisplay.appendChild(span);
        });

        // Re-add the cursor at the end
        const cursor = document.createElement("span");
        cursor.id = "typing-cursor";
        cursor.className =
          "inline-block w-2 h-[1em] bg-primary-light-500 animate-pulse";
        cursor.style.display = "none"; // Hide cursor after completion
        codeDisplay.appendChild(cursor);
      }

      // Call the callback to continue the animation
      const callback = this.currentTypeCallback;
      this.currentTypeCallback = null;
      this.pendingTypeCode = "";
      callback();
    }
  },

  // Parse Elixir code into tokens with their CSS classes
  parseElixirTokens(code) {
    const tokens = [];
    const keywords =
      /\b(defmodule|def|do|end|use|import|alias|require|case|cond|if|unless|when|fn|with)\b/g;
    const booleans = /\b(true|false|nil)\b/g;
    const atoms = /(:\w+)/g;
    const strings = /("[^"]*")/g;
    const comments = /(#[^\n]*)/g;
    const modules = /\b([A-Z]\w*(\.\w+)*)\b/g;
    const pipes = /(\|>)/g;
    const arrows = /(->)/g;

    let lastIndex = 0;
    const allMatches = [];

    // Collect all matches with their positions
    let match;
    while ((match = keywords.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-pink-400",
      });
    }
    while ((match = booleans.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-purple-400",
      });
    }
    while ((match = atoms.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-cyan-400",
      });
    }
    while ((match = strings.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-yellow-400",
      });
    }
    while ((match = comments.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-gray-500",
      });
    }
    while ((match = modules.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-blue-400",
      });
    }
    while ((match = pipes.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-pink-400",
      });
    }
    while ((match = arrows.exec(code)) !== null) {
      allMatches.push({
        start: match.index,
        end: match.index + match[0].length,
        text: match[0],
        className: "text-pink-400",
      });
    }

    // Sort by position
    allMatches.sort((a, b) => a.start - b.start);

    // Filter out overlapping matches, keeping the first one
    const filteredMatches = [];
    let lastEnd = 0;
    for (const match of allMatches) {
      if (match.start >= lastEnd) {
        filteredMatches.push(match);
        lastEnd = match.end;
      }
    }

    // Build tokens
    lastIndex = 0;
    for (const match of filteredMatches) {
      // Add plain text before this match
      if (match.start > lastIndex) {
        const plainText = code.substring(lastIndex, match.start);
        if (plainText) {
          tokens.push({ text: plainText, className: "text-gray-300" });
        }
      }

      // Add the highlighted match
      tokens.push({ text: match.text, className: match.className });
      lastIndex = match.end;
    }

    // Add remaining plain text
    if (lastIndex < code.length) {
      const remainingText = code.substring(lastIndex);
      if (remainingText) {
        tokens.push({ text: remainingText, className: "text-gray-300" });
      }
    }

    return tokens;
  },

  // Update progress dots
  updateProgressDots() {
    const dots = document.querySelectorAll(".stage-dot");
    dots.forEach((dot, index) => {
      if (index === this.currentStage) {
        dot.classList.add("bg-primary-light-500");
        dot.classList.remove("bg-primary-dark-500/30");
      } else if (index < this.currentStage) {
        dot.classList.add("bg-primary-dark-500");
        dot.classList.remove("bg-primary-dark-500/30", "bg-primary-light-500");
      } else {
        dot.classList.remove("bg-primary-light-500", "bg-primary-dark-500");
        dot.classList.add("bg-primary-dark-500/30");
      }
    });
  },

  // Update layout for final stage (hide code panel, make visualization full width)
  updateLayoutForStage(isFinalStage) {
    const gridContainer = document.querySelector(".grid");
    const codePanel = gridContainer?.querySelector(".relative:first-child");
    const visualizationPanel = document.getElementById("visualization-panel");

    if (isFinalStage) {
      // Hide code panel and make visualization full width
      if (codePanel) codePanel.style.display = "none";
      if (gridContainer) {
        gridContainer.classList.remove("lg:grid-cols-2");
        gridContainer.style.gridTemplateColumns = "1fr";
      }
      if (visualizationPanel) {
        visualizationPanel.style.gridColumn = "span 2";
        visualizationPanel.style.height = "600px";
      }
    } else {
      // Show code panel and restore two-column layout
      if (codePanel) codePanel.style.display = "block";
      if (gridContainer) {
        gridContainer.classList.add("lg:grid-cols-2");
        gridContainer.style.gridTemplateColumns = "";
      }
      if (visualizationPanel) {
        visualizationPanel.style.gridColumn = "";
        visualizationPanel.style.height = "";
      }
    }
  },

  // Update stage description panel and file path
  updateDescription(stageIndex) {
    const stage = this.stages[stageIndex];
    const descriptionPanel = document.getElementById("stage-description");
    const titleElement = document.getElementById("stage-title");
    const textElement = document.getElementById("stage-text");

    if (descriptionPanel && titleElement && textElement) {
      // Show description panel for all stages
      titleElement.textContent = stage.name;
      textElement.textContent = stage.description;
      descriptionPanel.style.display = "block";

      // Apply fade transition (skip if reduced motion or first stage)
      if (this.prefersReducedMotion || stageIndex === 0) {
        descriptionPanel.style.opacity = "1";
      } else {
        descriptionPanel.style.opacity = "0";
        setTimeout(() => {
          descriptionPanel.style.opacity = "1";
        }, 50);
      }
    }

    // Update file path display
    const filePathElement = document.querySelector(".text-gray-500.text-xs");
    if (filePathElement && stage.module) {
      const filePath = stage.module.toLowerCase().replace(/\./g, "/");
      filePathElement.textContent = `lib/${filePath}.ex`;
    }
  },

  // Add new visualization element with transition
  addVisualization(content, stageIndex) {
    const panel = document.getElementById("visualization-panel");

    // Create container for this stage
    const stageContainer = document.createElement("div");
    stageContainer.id = `stage-${stageIndex}`;
    stageContainer.className =
      "stage-visualization transition-all duration-500 ease-in-out";
    stageContainer.innerHTML = content;

    // Initially hidden for animation (skip if reduced motion or first stage)
    if (this.prefersReducedMotion || stageIndex === 0) {
      stageContainer.style.opacity = "1";
      stageContainer.style.transform = "translateY(0)";
    } else {
      stageContainer.style.opacity = "0";
      stageContainer.style.transform = "translateY(20px)";
    }

    panel.appendChild(stageContainer);

    // Animate in (skip if reduced motion or first stage)
    if (!this.prefersReducedMotion && stageIndex !== 0) {
      setTimeout(() => {
        stageContainer.style.opacity = "1";
        stageContainer.style.transform = "translateY(0)";
      }, 50);
    }
  },

  // Transition previous stages to summary versions
  transitionPreviousStagesToSummary(currentStage) {
    const panel = document.getElementById("visualization-panel");

    // Ensure summary grid exists
    let summaryGrid = document.getElementById("summary-grid");
    if (!summaryGrid && currentStage > 0) {
      summaryGrid = document.createElement("div");
      summaryGrid.id = "summary-grid";
      summaryGrid.className = "grid gap-4 mb-8";
      panel.insertBefore(summaryGrid, panel.firstChild);
    }

    for (let i = 0; i < currentStage; i++) {
      const prevStage = document.getElementById(`stage-${i}`);
      if (prevStage && !prevStage.classList.contains("stage-summary")) {
        // Create summary version
        const summaryContent = this.createSummaryForStage(i);

        // Animate transition and move to grid
        prevStage.style.transition = "all 0.5s ease-in-out";
        prevStage.style.transform = "scale(0.8)";
        prevStage.style.opacity = "0.7";

        setTimeout(() => {
          // Remove from current location
          prevStage.remove();

          // Add to summary grid
          this.addSummaryToGrid(summaryContent, i);
        }, 250);
      }
    }

    // Update grid layout after all summaries are processed
    if (summaryGrid && currentStage > 0) {
      const cols = Math.min(currentStage, 4);
      summaryGrid.className = `grid grid-cols-${cols} gap-4 mb-4`;
    }
  },

  // Update grid layout based on number of summary items
  updateGridLayout(currentStage) {
    const panel = document.getElementById("visualization-panel");

    if (currentStage > 0) {
      // Create or update summary grid container
      let summaryGrid = document.getElementById("summary-grid");
      if (!summaryGrid) {
        summaryGrid = document.createElement("div");
        summaryGrid.id = "summary-grid";
        summaryGrid.className = "grid gap-3 mb-6";
        panel.insertBefore(summaryGrid, panel.firstChild);
      }

      // Update grid columns based on number of summaries
      const cols = Math.min(currentStage, 4); // Max 4 columns
      summaryGrid.className = `grid grid-cols-${cols} gap-4 mb-8`;

      // Move existing summaries to grid
      const summaries = panel.querySelectorAll(".stage-summary");
      summaries.forEach((summary) => {
        if (summary.parentNode !== summaryGrid) {
          summaryGrid.appendChild(summary);
        }
      });
    }
  },

  // Create summary version for a specific stage
  createSummaryForStage(stageIndex) {
    switch (stageIndex) {
      case 0:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">Function</h3>
            </div>
            <div class="text-xs text-gray-400">
              <span class="text-primary-light-300">reading_time/1</span>
            </div>
          </div>
        `;
      case 1:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-blue-500" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.94-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">PostgreSQL</h3>
            </div>
            <div class="text-xs text-gray-400">Table: posts</div>
          </div>
        `;
      case 2:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-pink-500" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12,2 L2,7 L12,12 L22,7 L12,2 Z M2,17 L12,22 L22,17 L22,7 L12,12 L2,7 L2,17 Z"/>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">GraphQL</h3>
            </div>
            <div class="text-xs text-gray-400">API + Mutations</div>
          </div>
        `;
      case 3:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">JSON:API</h3>
            </div>
            <div class="text-xs text-gray-400">REST Routes</div>
          </div>
        `;
      case 4:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">Encryption</h3>
            </div>
            <div class="text-xs text-gray-400">Content field</div>
          </div>
        `;
      case 5:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">AI Tools</h3>
            </div>
            <div class="text-xs text-gray-400">LLM Actions</div>
          </div>
        `;
      case 6:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-yellow-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 11V9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">State Machine</h3>
            </div>
            <div class="text-xs text-gray-400">Draft/Published</div>
          </div>
        `;
      case 7:
        return `
          <div class="bg-slate-900/80 rounded-lg p-3 border border-primary-dark-500/20">
            <div class="flex items-center gap-2 mb-1">
              <svg class="w-4 h-4 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">Authentication</h3>
            </div>
            <div class="text-xs text-gray-400">Login/OAuth</div>
          </div>
        `;
      default:
        return "";
    }
  },

  // Clear all visualizations (for restart)
  clearAllVisualizations() {
    const panel = document.getElementById("visualization-panel");

    panel.innerHTML = "";
  },

  // Visualization creators
  createFunctionInterface() {
    return `
      <div class="w-full">
        <div class="bg-slate-900/80 rounded-lg p-6 border border-primary-dark-500/20">
          <h3 class="text-primary-light-400 font-semibold mb-4">Functional Interface</h3>
          <div class="text-center mb-6">
            <div class="bg-slate-800/70 rounded-lg p-4 font-mono">
              <span class="text-blue-400">MyApp.Blog.Post</span>.<span class="text-primary-light-300">reading_time</span>(<span class="text-yellow-400">"content string"</span>)
            </div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-sm">
            <div class="bg-slate-800/50 rounded p-3">
              <p class="text-gray-400 mb-2">Takes:</p>
              <p class="text-primary-light-300 font-mono">content: String</p>
            </div>
            <div class="bg-slate-800/50 rounded p-3">
              <p class="text-gray-400 mb-2">Returns:</p>
              <p class="text-primary-light-300 font-mono">Integer (minutes)</p>
            </div>
          </div>
          <div class="mt-4 p-4 bg-green-900/20 rounded border border-green-700/30">
            <p class="text-sm text-green-300 mb-1">Example:</p>
            <pre class="text-xs text-green-200 font-mono">reading_time("A long blog post...") → 3</pre>
          </div>
        </div>
      </div>
    `;
  },

  createPostgresTable() {
    return `
      <div class="w-full space-y-4">
        <div class="bg-slate-900/80 rounded-lg p-6 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-4">
            <svg class="w-6 h-6 text-blue-500" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 17.93c-3.94-.49-7-3.85-7-7.93 0-.62.08-1.21.21-1.79L9 15v1c0 1.1.9 2 2 2v1.93zm6.9-2.54c-.26-.81-1-1.39-1.9-1.39h-1v-3c0-.55-.45-1-1-1H8v-2h2c.55 0 1-.45 1-1V7h2c1.1 0 2-.9 2-2v-.41c2.93 1.19 5 4.06 5 7.41 0 2.08-.8 3.97-2.1 5.39z"/>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">PostgreSQL Table: posts</h3>
          </div>
          <div class="overflow-hidden rounded border border-primary-dark-500/20">
            <table class="w-full text-sm">
              <thead>
                <tr class="bg-slate-800/50">
                  <th class="px-4 py-2 text-left text-gray-400">Column</th>
                  <th class="px-4 py-2 text-left text-gray-400">Type</th>
                </tr>
              </thead>
              <tbody class="divide-y divide-primary-dark-500/10">
                <tr><td class="px-4 py-2 text-primary-light-300">id</td><td class="px-4 py-2 text-gray-500">uuid</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">title</td><td class="px-4 py-2 text-gray-500">text</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">content</td><td class="px-4 py-2 text-gray-500">text</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">status</td><td class="px-4 py-2 text-gray-500">text</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">created_at</td><td class="px-4 py-2 text-gray-500">timestamp</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">updated_at</td><td class="px-4 py-2 text-gray-500">timestamp</td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    `;
  },

  createGraphQLPanel() {
    return `
      <div class="w-full">
        <div class="bg-slate-900/80 rounded-lg p-4 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-3">
            <svg class="w-6 h-6 text-pink-500" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12,2 L2,7 L12,12 L22,7 L12,2 Z M2,17 L12,22 L22,17 L22,7 L12,12 L2,7 L2,17 Z"/>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">GraphQL API</h3>
          </div>
          <div class="space-y-3">
            <div class="p-3 bg-slate-800/50 rounded">
              <p class="text-sm text-gray-400 mb-1">Query</p>
              <pre class="text-xs text-primary-light-300">query GetPost($id: ID!) {
  post(id: $id) {
    id
    title
  }
}</pre>
            </div>
            <div class="p-3 bg-slate-800/50 rounded">
              <p class="text-sm text-gray-400 mb-1">Mutation</p>
              <pre class="text-xs text-primary-light-300">mutation CreatePost($input: CreatePostInput!) {
  createPost(input: $input) {
    id
    title
  }
}</pre>
            </div>
          </div>
        </div>
      </div>
    `;
  },

  createJsonApiPanel() {
    return `
      <div class="w-full">
        <div class="bg-slate-900/80 rounded-lg p-4 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-3">
            <svg class="w-6 h-6 text-orange-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M8 9l3 3-3 3m5 0h3M5 20h14a2 2 0 002-2V6a2 2 0 00-2-2H5a2 2 0 00-2 2v14a2 2 0 002 2z"></path>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">JSON:API REST Endpoints</h3>
          </div>
          <div class="space-y-2">
            <div class="grid grid-cols-2 gap-2 text-xs">
              <div class="p-2 bg-slate-800/50 rounded">
                <span class="text-green-400 font-mono">GET</span>
                <span class="text-gray-300 ml-2">/posts</span>
              </div>
              <div class="p-2 bg-slate-800/50 rounded">
                <span class="text-green-400 font-mono">GET</span>
                <span class="text-gray-300 ml-2">/posts/:id</span>
              </div>
              <div class="p-2 bg-slate-800/50 rounded">
                <span class="text-blue-400 font-mono">POST</span>
                <span class="text-gray-300 ml-2">/posts</span>
              </div>
              <div class="p-2 bg-slate-800/50 rounded">
                <span class="text-yellow-400 font-mono">PATCH</span>
                <span class="text-gray-300 ml-2">/posts/:id</span>
              </div>
            </div>
            <div class="p-3 bg-slate-800/50 rounded mt-3">
              <p class="text-sm text-gray-400 mb-1">Example Response</p>
              <pre class="text-xs text-primary-light-300">{
  "data": {
    "type": "post",
    "id": "123",
    "attributes": {
      "title": "My Post",
      "content": "Post content..."
    }
  }
}</pre>
            </div>
          </div>
        </div>
      </div>
    `;
  },

  createAiToolsPanel() {
    return `
      <div class="w-full">
        <div class="bg-slate-900/80 rounded-lg p-4 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-3">
            <svg class="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"></path>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">AI-Powered Actions & Tools</h3>
          </div>
          <div class="space-y-3">
            <div class="p-3 bg-slate-800/50 rounded">
              <p class="text-sm text-gray-400 mb-1">Prompt-Backed Action</p>
              <pre class="text-xs text-primary-light-300">analyze_sentiment(content: "Great post!")
→ :positive</pre>
            </div>
            <div class="p-3 bg-slate-800/50 rounded">
              <p class="text-sm text-gray-400 mb-1">MCP Tools Exposed</p>
              <div class="text-xs space-y-1">
                <div class="text-gray-300">🔧 create_post</div>
                <div class="text-gray-300">🔧 read_posts</div>
                <div class="text-gray-300">🔧 update_post</div>
                <div class="text-gray-300">🔧 analyze_sentiment</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
  },

  createAuthenticationPanel() {
    return `
      <div class="w-full">
        <div class="bg-slate-900/80 rounded-lg p-4 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-3">
            <svg class="w-6 h-6 text-blue-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"></path>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">User Authentication</h3>
          </div>
          <div class="space-y-3">
            <div class="p-3 bg-slate-800/50 rounded">
              <p class="text-sm text-gray-400 mb-1">Authentication Strategies</p>
              <div class="text-xs space-y-1">
                <div class="text-gray-300">🔐 Password</div>
                <div class="text-gray-300">✉️ Magic Link</div>
                <div class="text-gray-300">🔑 Api Key</div>
                <div class="text-gray-300">🐙 GitHub</div>
                <div class="text-gray-300">🔍 Google</div>
                <div class="text-gray-300">💼 Slack</div>
                <div class="text-gray-300">🧩 Custom</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `;
  },

  createEncryptionFlow() {
    return `
      <div class="w-full space-y-4">
        <div class="bg-slate-900/80 rounded-lg p-6 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-4">
            <svg class="w-6 h-6 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">Encryption at Rest</h3>
          </div>
          <div class="flex items-center justify-between gap-4">
            <div class="flex-1 text-center">
              <div class="p-4 bg-slate-800/50 rounded">
                <p class="text-sm text-gray-400 mb-2">Application</p>
                <p class="text-primary-light-300 font-mono text-sm">"Hello World"</p>
              </div>
            </div>
            <svg class="w-8 h-8 text-primary-dark-500 animate-pulse" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 7l5 5m0 0l-5 5m5-5H6"></path>
            </svg>
            <div class="flex-1 text-center">
              <div class="p-4 bg-slate-800/50 rounded">
                <p class="text-sm text-gray-400 mb-2">Database</p>
                <p class="text-green-400 font-mono text-xs">AES256:B64:IV...</p>
              </div>
            </div>
          </div>
          <p class="text-sm text-gray-500 text-center mt-4">Content field automatically encrypted/decrypted</p>
        </div>
      </div>
    `;
  },

  createStateMachine() {
    return `
      <div class="w-full space-y-4">
        <div class="bg-slate-900/80 rounded-lg p-6 border border-primary-dark-500/20">
          <div class="flex items-center gap-2 mb-4">
            <svg class="w-6 h-6 text-purple-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"></path>
            </svg>
            <h3 class="text-primary-light-400 font-semibold">State Machine</h3>
          </div>
          <div class="flex items-center justify-center gap-8">
            <div class="text-center">
              <div class="w-24 h-24 rounded-full bg-yellow-500/20 border-2 border-yellow-500 flex items-center justify-center">
                <span class="text-yellow-400 font-semibold">Draft</span>
              </div>
            </div>
            <div class="flex flex-col gap-2">
              <div class="flex items-center gap-2">
                <svg class="w-8 h-6 text-primary-dark-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                </svg>
                <span class="text-xs text-gray-400">publish</span>
              </div>
              <div class="flex items-center gap-2">
                <svg class="w-8 h-6 text-primary-dark-500 rotate-180" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14 5l7 7m0 0l-7 7m7-7H3"></path>
                </svg>
                <span class="text-xs text-gray-400">unpublish</span>
              </div>
            </div>
            <div class="text-center">
              <div class="w-24 h-24 rounded-full bg-green-500/20 border-2 border-green-500 flex items-center justify-center">
                <span class="text-green-400 font-semibold">Published</span>
              </div>
            </div>
          </div>
          <div class="mt-6 text-center">
            <p class="text-sm text-gray-500">Describe and validate state transitions</p>
          </div>
        </div>
      </div>
    `;
  },

  createObanPanel() {
    return `
      <div class="w-full">
        <div class="bg-gradient-to-br from-orange-50 to-yellow-50 dark:from-orange-900/20 dark:to-yellow-900/20 rounded-lg p-4 border border-orange-200 dark:border-orange-700">
          <div class="text-center mb-3">
            <h3 class="text-xl font-bold text-orange-700 dark:text-orange-300 mb-0">Background Job Processing</h3>
          </div>

          <div class="grid md:grid-cols-2 gap-4">
            <!-- Triggers Panel -->
            <div class="bg-white dark:bg-gray-800 rounded-lg p-3 border border-orange-200 dark:border-orange-700">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-2 h-2 bg-orange-500 rounded-full"></div>
                <h4 class="font-semibold text-sm text-orange-700 dark:text-orange-300">Triggers</h4>
              </div>
              <p class="text-xs text-gray-600 dark:text-gray-400 mb-2">
                Run actions for records matching conditions on a schedule
              </p>
              <div class="space-y-1">
                <div class="bg-orange-50 dark:bg-orange-900/20 rounded p-2 text-xs">
                  <div class="text-orange-700 dark:text-orange-300 font-mono text-xs">publish</div>
                  <div class="text-gray-600 dark:text-gray-400 text-xs">Runs hourly to publish pending posts</div>
                </div>
              </div>
            </div>

            <!-- Scheduled Actions Panel -->
            <div class="bg-white dark:bg-gray-800 rounded-lg p-3 border border-yellow-200 dark:border-yellow-700">
              <div class="flex items-center gap-2 mb-2">
                <div class="w-2 h-2 bg-yellow-500 rounded-full"></div>
                <h4 class="font-semibold text-sm text-yellow-700 dark:text-yellow-300">Scheduled Actions</h4>
              </div>
              <p class="text-xs text-gray-600 dark:text-gray-400 mb-2">
                Run generic actions on cron schedules
              </p>
              <div class="space-y-1">
                <div class="bg-yellow-50 dark:bg-yellow-900/20 rounded p-2 text-xs">
                  <div class="text-yellow-700 dark:text-yellow-300 font-mono text-xs">cleanup_old_drafts</div>
                  <div class="text-gray-600 dark:text-gray-400 text-xs">Runs daily to clean up old draft posts</div>
                </div>
              </div>
            </div>
          </div>

          <div class="mt-2 text-center">
            <a href="https://getoban.pro" target="_blank" class="mt-2 text-center">
              <div class="inline-flex items-center gap-1 px-3 py-1 bg-gradient-to-r from-orange-100 to-yellow-100 dark:from-orange-800 dark:to-yellow-800 rounded-full">
                <span class="text-xs font-medium text-orange-700 dark:text-orange-300">Powered by Oban</span>
                <svg class="w-3 h-3 text-orange-600 dark:text-orange-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13 10V3L4 14h7v7l9-11h-7z"></path>
                </svg>
              </div>
            </a>
          </div>
        </div>
      </div>
    `;
  },

  // Generate URL slug from stage name
  getStageSlug(stageIndex) {
    const stage = this.stages[stageIndex];
    return stage.name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");
  },

  // Get stage index from URL slug
  getStageFromSlug(slug) {
    for (let i = 0; i < this.stages.length; i++) {
      if (this.getStageSlug(i) === slug) {
        return i;
      }
    }
    return 0; // Default to first stage if not found
  },

  // Copy link to current stage
  copyStageLink() {
    const slug = this.getStageSlug(this.currentStage);
    const url = `${window.location.origin}${window.location.pathname}#ash-animation-${slug}`;

    navigator.clipboard
      .writeText(url)
      .then(() => {
        // Show feedback that link was copied
        const linkBtn = document.getElementById("link-stage");
        if (linkBtn) {
          const originalHTML = linkBtn.innerHTML;

          // Change to checkmark icon and green background
          linkBtn.style.backgroundColor = "#10b981"; // green
          linkBtn.innerHTML = `
          <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
          </svg>
        `;

          // Create and show tooltip
          const tooltip = document.createElement("div");
          tooltip.textContent = "Link copied!";
          tooltip.style.cssText = `
          position: absolute;
          top: 50%;
          right: -120px;
          transform: translateY(-50%);
          background: #10b981;
          color: white;
          padding: 8px 12px;
          border-radius: 6px;
          font-size: 14px;
          font-weight: 500;
          z-index: 1000;
          white-space: nowrap;
          animation: fadeIn 0.2s ease-in;
        `;
          linkBtn.style.position = "relative";
          linkBtn.appendChild(tooltip);

          setTimeout(() => {
            linkBtn.style.backgroundColor = ""; // reset
            linkBtn.innerHTML = originalHTML; // restore original icon
            if (tooltip.parentElement) {
              tooltip.parentElement.removeChild(tooltip);
            }
          }, 2000);
        }
      })
      .catch(() => {
        // Fallback for older browsers
        prompt("Copy this link:", url);
      });
  },

  // Check URL hash and jump to stage if specified
  handleUrlHash() {
    const hash = window.location.hash;
    if (hash.startsWith("#ash-animation-")) {
      const slug = hash.replace("#ash-animation-", "");
      const stageIndex = this.getStageFromSlug(slug);
      if (stageIndex !== this.currentStage) {
        this.currentStage = stageIndex;

        // Check if we're on mobile (lg:hidden is active)
        const mobileContainer = document.getElementById("mobile-stages");
        const isMobile = mobileContainer && window.innerWidth < 1024; // lg breakpoint

        if (isMobile) {
          // Handle mobile navigation
          this.mobileCurrentStage = stageIndex;
          this.updateMobileStage();
          this.updateMobileStageContent();
        } else {
          // Handle desktop navigation
          this.cancelPendingOperations();
          this.pause();
          this.animationActive = false;
          this.isPlaying = false;
          this.loadedFromHash = true;
          this.showStageProgressive(stageIndex);

          // Complete any typing to show all text
          setTimeout(() => {
            this.completeCurrentTyping();
            this.updatePlayPauseButton(false);
          }, 100);
        }

        // Scroll to animation container and start animation
        this.scrollToAnimationIfNeeded();
      }
      return true; // Hash was processed
    }
    return false; // No hash processed
  },

  // Scroll to animation container if it's not in view
  scrollToAnimationIfNeeded() {
    const container = document.getElementById("ash-animation");
    if (!container) return;

    // Always scroll to container when hash is present
    container.scrollIntoView({ behavior: "smooth", block: "start" });

    // Manually trigger animation start after scroll
    setTimeout(() => {
      if (!this.hasBeenInitiated) {
        this.hasBeenInitiated = true;
        this.start();
      }
    }, 500);
  },
};

// Initialize animation when DOM is ready
document.addEventListener("DOMContentLoaded", () => {
  AshAnimation.init();
});

// Handle URL hash changes
window.addEventListener("hashchange", () => {
  AshAnimation.handleUrlHash();
});
