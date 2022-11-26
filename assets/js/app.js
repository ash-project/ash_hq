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
import topbar from "../vendor/topbar";
import mermaid from "mermaid";
mermaid.init(".mermaid");

function cookiesAreAllowed() {
  const consentStatus = document.cookie
    .split("; ")
    .find((row) => row.startsWith("cookieconsent_status="));

  return consentStatus === "cookieconsent_status=allow";
}

function get_platform() {
    // 2022 way of detecting. Note : this userAgentData feature is available only in secure contexts (HTTPS)
    if (typeof navigator.userAgentData !== 'undefined' && navigator.userAgentData != null) {
        return navigator.userAgentData.platform;
    }
    // Deprecated but still works for most of the browser
    if (typeof navigator.platform !== 'undefined') {
        if (typeof navigator.userAgent !== 'undefined' && /android/.test(navigator.userAgent.toLowerCase())) {
            // android device's navigator.platform is often set as 'linux', so let's use userAgent for them
            return 'android';
        }
        return navigator.platform;
    }
    return 'unknown';
}

let platform = get_platform();

let isOSX = /mac/.test(platform.toLowerCase()); // Mac desktop

const Hooks = {};

let configuredThemeRow;
if (cookiesAreAllowed()) {
  configuredThemeRow = document.cookie
    .split("; ")
    .find((row) => row.startsWith("theme="));
}

if (!configuredThemeRow) {
  let theme;
  if (
    window.matchMedia &&
    window.matchMedia("(prefers-color-scheme: dark)").matches
  ) {
    setTheme("dark");
  } else {
    setTheme("light");
  }
}

window
  .matchMedia("(prefers-color-scheme: dark)")
  .addEventListener("change", (event) => {
    let configuredThemeRow;
    if (cookiesAreAllowed()) {
      configuredThemeRow = document.cookie
        .split("; ")
        .find((row) => row.startsWith("theme="));
    }

    if (!configuredThemeRow || configuredThemeRow === "theme=system") {
      setTheme("system");
    } else {
      if (configuredThemeRow === "theme=dark") {
        setTheme("dark");
      } else if (configuredThemeRow === "theme=light") {
        setTheme("light");
      } else {
        setTheme("system");
      }
    }
  });

function setTheme(theme, set) {
  let setTheme;
  if (theme == "system") {
    if (
      window.matchMedia &&
      window.matchMedia("(prefers-color-scheme: dark)").matches
    ) {
      setTheme = "dark";
    } else {
      setTheme = "light";
    }
  } else {
    setTheme = theme;
  }

  document.documentElement.classList.add(setTheme);

  if (setTheme === "dark") {
    document.documentElement.classList.remove("light");
  } else {
    document.documentElement.classList.remove("dark");
  }

  if (set && cookiesAreAllowed()) {
    document.cookie = "theme" + "=" + theme + ";path=/";
  }
}

Hooks.ColorTheme = {
  mounted() {
    this.handleEvent("set_theme", (payload) => {
      setTheme(payload.theme, true);
    });
  },
};

Hooks.Docs = {
  mounted() {
    mermaid.init(".mermaid");
  },
};

let scrolled = false;

Hooks.RightNav = {
  mounted() {
    this.intersectionObserver =
      new IntersectionObserver((entries) =>
        this.onScrollChange(entries), { rootMargin: "-10% 0px -89% 0px" }
      );

    this.observeElements()
    window.addEventListener("hashchange", (event) => { this.handleHashChange(); });
  },
  updated() {
    this.intersectionObserver.disconnect();
    this.observeElements();
  },
  observeElements() {
    for (el of document.querySelectorAll("#docs-window .nav-anchor")) {
      this.intersectionObserver.observe(el);
    }
  },
  onScrollChange(entries) {
    // Wait for scrolling from initial page load to complete
    if (!scrolled) { return; }

    for (entry of entries) {
      if (entry.isIntersecting) {
        this.setAriaCurrent(entry.target.id);
        history.pushState(null, null, `#${entry.target.id}`);
      }
    }
  },
  handleHashChange() {
    if (window.location.hash) {
      this.setAriaCurrent(window.location.hash.substring(1))

      // Disable the insersection observer for 1s while the browser
      // scrolls the selected element to the top.
      scrolled = false;
      setTimeout(() => { scrolled = true }, 1000);
    }
  },
  setAriaCurrent(id) {
    const el = document.getElementById("right-nav-" + id);
    if (el) {
      for (elem of document.querySelectorAll('#right-nav a[aria-current]')) {
        elem.removeAttribute('aria-current');
      }
      el.setAttribute("aria-current", "true");
    }
  }
}

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

// Show progress bar on live navigation and form submits. Only displays if still
// loading after 120 msec
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });

let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  scrolled = false;

  // close mobile sidebar on navigation
  mobileSideBar = document.getElementById("mobile-sidebar-hide")
  if (mobileSideBar) {
    mobileSideBar.click()
  }

  if (!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 250);
  }
});

window.addEventListener("phx:page-loading-stop", ({ detail }) => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  let scrollEl;
  if (detail.kind === "initial" && window.location.hash) {
    scrollEl = document.getElementById(window.location.hash.substring(1));
  } else if (detail.kind == "patch" && !window.location.hash) {
    scrollEl = document.querySelector("#docs-window .nav-anchor") || document.querySelector("#docs-window h1");
  }
  if (scrollEl) {
    Hooks.RightNav.setAriaCurrent(scrollEl.id);
    // Not using scroll polyfill here - doesn't respect scroll-padding-top CSS
    scrollEl.scrollIntoView({block: 'start'})
    setTimeout(() => { scrolled = true; }, 1000);
  } else {
    scrolled = true;
  }
  topbar.hide();
});

window.addEventListener("js:focus", (e) => e.target.focus());

window.addEventListener("phx:js:scroll-to", (e) => {
  const target = document.getElementById(e.detail.id);
  const boundary = target.closest(".scroll-parent");
  scrollIntoView(target, {
    behavior: "smooth",
    block: "start",
    boundary: boundary,
  });
});

window.addEventListener("phx:selected-versions", (e) => {
  if (cookiesAreAllowed()) {
    const cookie = Object.keys(e.detail)
      .map((key) => `${key}:${e.detail[key]}`)
      .join(",");
    document.cookie = "selected_versions" + "=" + cookie + ";path=/";
  }
});

window.addEventListener("phx:selected-types", (e) => {
  if (cookiesAreAllowed()) {
    const cookie = e.detail.types.join(",");
    document.cookie = "selected_types" + "=" + cookie + ";path=/";
  }
});

window.addEventListener("keydown", (event) => {
  if ((event.metaKey || event.ctrlKey) && event.key === "k") {
    document.getElementById("search-button").click();
    event.preventDefault();
  }
});
window.addEventListener("keydown", (event) => {
  if (event.key === "Escape") {
    const closeSearchVersions = document.getElementById("close-search-versions");
    if (closeSearchVersions && closeSearchVersions.offsetParent !== null) {
      closeSearchVersions.click()
    } else {
      document.getElementById("close-search").click();
    }
    event.preventDefault();
  }
});

window.addEventListener("phx:click-on-item", (event) => {
  document.getElementById(event.detail.id).click();
  document.getElementById("close-search").click();
  event.preventDefault();
});

window.addEventListener("phx:close-search", (event) => {
  document.getElementById("close-search").click();
  event.preventDefault();
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// liveSocket.disableDebug();
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

window.addEventListener("load", function () {
  window.cookieconsent.initialise({
    content: {
      message:
        "Hi, this website uses essential cookies for remembering your explicitly set preferences, if you opt-in. We do not use google analytics, but we do use plausible.io, an ethical google analytics alternative which does not use any cookies and collects no personal data.",
      link: null,
    },
    type: "opt-in",
    palette: {
      popup: {
        background: "#000",
      },
      button: {
        background: "#f1d600",
      },
    },
  });
});
