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

// Ash Interactive Animation
const AshAnimation = {
  // Animation stages with code snippets
  stages: [
    {
      name: "Pure Behavior",
      code: `
  actions do
    action :reading_time, :integer do
      argument :content, :string, allow_nil?: false

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
      name: "Add Persistence",
      code: `
    data_layer: AshPostgres.DataLayer

  postgres do
    table "posts"
    repo MyBlog.Repo
  end

  attributes do
    uuid_primary_key :id
    attribute :title, :string, allow_nil?: false
    attribute :content, :string

    timestamps()
  end

  actions do
    defaults [:read, create: [:title, :content]]

    update :rename do
      accept [:title]
    end

    # ...
  end`,
      visualizer: () => AshAnimation.createPostgresTable(),
    },
    {
      name: "Add GraphQL",
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

  # ...`,
      visualizer: () => AshAnimation.createGraphQLPanel(),
    },
    {
      name: "Add Encryption",
      code: `
    extensions: [
      AshGraphql.Resource,
      AshCloak.Resource
    ]

  cloak do
    vault MyBlog.Vault
    # Encrypt the content attribute
    attributes [:content]
  end

  # ...`,
      visualizer: () => AshAnimation.createEncryptionFlow(),
    },
    {
      name: "Add State Machine",
      code: `
    extensions: [
      AshGraphql.Resource,
      AshCloak.Resource,
      AshStateMachine
    ]

  state_machine do
    initial_states [:draft]
    default_initial_state :draft

    transitions do
      transition :publish, from: :draft, to: :published
      transition :unpublish, from: :published, to: :draft
    end
  end

  # ...`,
      visualizer: () => AshAnimation.createStateMachine(),
    },
  ],

  // State
  currentStage: 0,
  typingInterval: null,
  animationActive: false,
  observer: null,
  isPlaying: true,
  playInterval: null,
  hasBeenInitiated: false,

  // Initialize the animation
  init() {
    console.log("AshAnimation.init() called");
    const container = document.getElementById("ash-animation");
    if (!container) {
      console.log("Container not found!");
      return;
    }
    console.log("Container found, setting up...");

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

    // Set up intersection observer to start animation when visible
    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (
            entry.isIntersecting &&
            entry.intersectionRatio > 0.5 &&
            !this.hasBeenInitiated
          ) {
            console.log("Animation visible, starting...");
            this.hasBeenInitiated = true;
            this.start();
          }
        });
      },
      { threshold: 0.5 },
    );

    this.observer.observe(container);

    // Set initial play/pause button state
    const playIcon = document.getElementById("play-icon");
    const pauseIcon = document.getElementById("pause-icon");
    if (playIcon) playIcon.classList.add("hidden");
    if (pauseIcon) pauseIcon.classList.remove("hidden");
  },

  // Navigate to previous stage
  previousStage() {
    if (this.currentStage > 0) {
      this.pause();
      this.currentStage--;
      this.showStageProgressive(this.currentStage);
      this.updatePlayPauseButton(false);
    }
  },

  // Navigate to next stage
  nextStage() {
    if (this.currentStage < this.stages.length - 1) {
      this.pause();
      this.currentStage++;
      this.showStageProgressive(this.currentStage);
      this.updatePlayPauseButton(false);
    }
  },

  // Show stage for manual navigation (clears and rebuilds)
  showStageManual(stageIndex) {
    console.log("showStageManual called for stage:", stageIndex);
    this.currentStage = stageIndex;
    this.updateNavigationButtons();
    this.updateProgressDots();

    // Clear all visualizations and rebuild up to current stage
    this.clearAllVisualizations();

    const stage = this.stages[stageIndex];
    const codeDisplay = document.getElementById("code-display");

    // Set base content
    if (stageIndex === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  `;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
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

    // Build up all visualizations through current stage
    for (let i = 0; i <= stageIndex; i++) {
      this.addVisualization(this.stages[i].visualizer(), i);
    }
  },

  // Show a specific stage for initial load
  showStage(stageIndex) {
    console.log("showStage called for stage:", stageIndex);
    this.showStageProgressive(stageIndex);
  },

  // Show stage with progressive accumulation (for both manual nav and initial load)
  showStageProgressive(stageIndex) {
    this.currentStage = stageIndex;
    this.updateNavigationButtons();
    this.updateProgressDots();

    // Always clear and rebuild to ensure clean state
    this.clearAllVisualizations();

    const stage = this.stages[stageIndex];
    const codeDisplay = document.getElementById("code-display");

    // Set base content
    if (stageIndex === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  `;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
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

    // Build up all visualizations through current stage progressively
    this.buildProgressiveVisualizations(stageIndex);
  },

  // Build visualizations progressively showing accumulation
  buildProgressiveVisualizations(targetStage) {
    // Add each stage's visualization in sequence
    for (let i = 0; i <= targetStage; i++) {
      setTimeout(() => {
        if (i < targetStage) {
          // Add previous stages as summaries
          const summaryContent = this.createSummaryForStage(i);
          this.addSummaryToGrid(summaryContent, i);
        } else {
          // Add current stage as full visualization
          this.addVisualization(this.stages[i].visualizer(), i);
        }
      }, i * 100); // Stagger the animations slightly
    }
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

    // Add with animation
    summaryContainer.style.opacity = "0";
    summaryContainer.style.transform = "translateY(10px)";
    summaryGrid.appendChild(summaryContainer);

    setTimeout(() => {
      summaryContainer.style.opacity = "1";
      summaryContainer.style.transform = "translateY(0)";
    }, 50);
  },

  // Start the animation with typing
  start() {
    console.log("Animation start() called");
    if (this.animationActive) return;
    this.animationActive = true;
    this.animate();
  },

  // Main animation loop with typing
  animate() {
    console.log("animate() called for stage:", this.currentStage);
    if (!this.animationActive) return;

    const stage = this.stages[this.currentStage];
    const codeDisplay = document.getElementById("code-display");

    // Reset to base content when starting new stage
    if (this.currentStage === 0) {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>
  <span id="typing-cursor" class="inline-block w-2 h-[1em] bg-primary-light-500 animate-pulse"></span>`;
    } else {
      codeDisplay.innerHTML = `<span class="text-pink-400">defmodule</span> <span class="text-blue-400">MyBlog.Post</span> <span class="text-pink-400">do</span>
  <span class="text-pink-400">use</span> <span class="text-blue-400">Ash.Resource</span>,
<span id="typing-cursor" class="inline-block w-2 h-[1em] bg-primary-light-500 animate-pulse"></span>`;
    }
    this.updateProgressDots();

    // Clear all visualizations only when restarting (stage 0)
    if (this.currentStage === 0) {
      this.clearAllVisualizations();
    }

    // Transition previous stages to summary immediately when typing starts
    this.transitionPreviousStagesToSummary(this.currentStage);

    // Add new visualization immediately when typing starts
    setTimeout(() => {
      console.log(
        "AUTOPLAY: Adding visualization for stage:",
        this.currentStage,
      );
      this.addVisualization(stage.visualizer(), this.currentStage);
    }, 200);

    // Type the code (trim leading newline for stages 2+ to prevent extra blank line)
    const codeToType =
      this.currentStage >= 1 ? stage.code.replace(/^\n/, "") : stage.code;
    this.typeCode(codeToType, () => {
      console.log("typeCode callback for stage:", this.currentStage);
      // Hide cursor after typing
      const cursor = document.getElementById("typing-cursor");
      if (cursor) {
        cursor.style.display = "none";
      }

      // Wait before moving to next stage
      setTimeout(() => {
        this.currentStage = (this.currentStage + 1) % this.stages.length;
        console.log("Moving to next stage:", this.currentStage);

        // Update navigation buttons after stage change
        this.updateNavigationButtons();

        // Continue animation if active
        if (this.animationActive) {
          this.animate();
        }
      }, 4000);
    });
  },

  // Toggle autoplay
  togglePlayPause() {
    if (this.isPlaying) {
      this.pause();
      this.updatePlayPauseButton(false);
    } else {
      this.isPlaying = true;
      this.animationActive = true;
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
    if (this.typingInterval) {
      clearInterval(this.typingInterval);
      this.typingInterval = null;
    }
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
        const delay =
          char === "\n" ? 150 : char === " " ? 30 : 40 + Math.random() * 20;
        setTimeout(type, delay);
      } else {
        callback();
      }
    };

    type();
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

    // Build tokens
    lastIndex = 0;
    for (const match of allMatches) {
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

  // Add new visualization element with transition
  addVisualization(content, stageIndex) {
    const panel = document.getElementById("visualization-panel");
    console.log(
      "addVisualization called for stage",
      stageIndex,
      "panel has",
      panel.children.length,
      "children",
    );

    // Create container for this stage
    const stageContainer = document.createElement("div");
    stageContainer.id = `stage-${stageIndex}`;
    stageContainer.className =
      "stage-visualization transition-all duration-500 ease-in-out";
    stageContainer.innerHTML = content;

    // Initially hidden for animation
    stageContainer.style.opacity = "0";
    stageContainer.style.transform = "translateY(20px)";

    panel.appendChild(stageContainer);
    console.log(
      "Panel after adding stage",
      stageIndex,
      ":",
      panel.children.length,
      "children",
    );

    // Animate in
    setTimeout(() => {
      stageContainer.style.opacity = "1";
      stageContainer.style.transform = "translateY(0)";
    }, 100);
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
              <svg class="w-4 h-4 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"></path>
              </svg>
              <h3 class="text-primary-light-400 font-semibold text-sm">Encrypted</h3>
            </div>
            <div class="text-xs text-gray-400">Content field</div>
          </div>
        `;
      default:
        return "";
    }
  },

  // Clear all visualizations (for restart)
  clearAllVisualizations() {
    const panel = document.getElementById("visualization-panel");
    console.log(
      "clearAllVisualizations called - panel had",
      panel.children.length,
      "children",
    );
    console.trace("clearAllVisualizations called from:");
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
              <span class="text-blue-400">MyBlog.Post</span>.<span class="text-primary-light-300">reading_time</span>(<span class="text-yellow-400">"content string"</span>)
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
                <tr><td class="px-4 py-2 text-primary-light-300">title</td><td class="px-4 py-2 text-gray-500">string</td></tr>
                <tr><td class="px-4 py-2 text-primary-light-300">content</td><td class="px-4 py-2 text-gray-500">text</td></tr>
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
    content
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
            <p class="text-sm text-gray-500">Transitions automatically exposed as GraphQL mutations</p>
          </div>
        </div>
      </div>
    `;
  },
};

// Initialize animation when DOM is ready
document.addEventListener("DOMContentLoaded", () => {
  console.log("DOM loaded, initializing AshAnimation...");
  AshAnimation.init();
});
