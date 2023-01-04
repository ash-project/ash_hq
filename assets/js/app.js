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

Hooks.Snowflakes = {
  mounted() {
    generateSnowflakes()
    window.addEventListener("resize", setResetFlag, false);
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
        history.replaceState(null, null, `#${entry.target.id}`);
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
    topBarScheduled = setTimeout(() => topbar.show(), 500);
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

// Snow below
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

  // Array to store our Snowflake objects
  let snowflakes = [];

  // Global variables to store our browser's window size
  let browserWidth;
  let browserHeight;

  // Specify the number of snowflakes you want visible
  let numberOfSnowflakes = 50;

  // Flag to reset the position of the snowflakes
  let resetPosition = false;

  // Handle accessibility
  let enableAnimations = false;
  let reduceMotionQuery = matchMedia("(prefers-reduced-motion)");

  // Handle animation accessibility preferences
  function setAccessibilityState() {
    if (reduceMotionQuery.matches) {
      enableAnimations = false;
    } else {
      enableAnimations = true;
    }

    const isChristmas = document.cookie
    .split("; ")
    .find((row) => row.startsWith("christmas="));
    if (isChristmas === "christmas=false") {
      enableAnimations = false
    }
  }
  setAccessibilityState();

  reduceMotionQuery.addListener(setAccessibilityState);

window.addEventListener("phx:toggle-christmas", ((e) => {
  if (cookiesAreAllowed()) {
    const cookie = e.detail.christmas;
    document.cookie = "christmas" + "=" + cookie + ";path=/";
  }

  setAccessibilityState()
}))

  //
  // Constructor for our Snowflake object
  //
  class Snowflake {
    constructor(element, speed, xPos, yPos) {
      // set initial snowflake properties
      this.element = element;
      this.speed = speed;
      this.xPos = xPos;
      this.yPos = yPos;
      this.scale = 1;

      // declare variables used for snowflake's motion
      this.counter = 0;
      this.sign = Math.random() < 0.5 ? 1 : -1;

      // setting an initial opacity and size for our snowflake
      this.element.style.opacity = (0.1 + Math.random()) / 3;
    }

    // The function responsible for actually moving our snowflake
    update(delta) {
      // using some trigonometry to determine our x and y position
      this.counter += (this.speed / 5000) * delta;
      this.xPos += (this.sign * delta * this.speed * Math.cos(this.counter)) / 40;
      this.yPos += Math.sin(this.counter) / 40 + (this.speed * delta) / 30;
      this.scale = 0.5 + Math.abs((10 * Math.cos(this.counter)) / 20);

      // setting our snowflake's position
      setTransform(
        Math.round(this.xPos),
        Math.round(this.yPos),
        this.scale,
        this.element
      );

      // if snowflake goes below the browser window, move it back to the top
      if (this.yPos > browserHeight) {
        this.yPos = -50;
      }
    }
  }

  //
  // A performant way to set your snowflake's position and size
  //
  function setTransform(xPos, yPos, scale, el) {
    el.style.transform = `translate3d(${xPos}px, ${yPos}px, 0) scale(${scale}, ${scale})`;
  }

  //
  // The function responsible for creating the snowflake
  //
  function generateSnowflakes() {
    // get our snowflake element from the DOM and store it
    let originalSnowflake = document.querySelector(".snowflake");

    // access our snowflake element's parent container
    let snowflakeContainer = originalSnowflake.parentNode;
    snowflakeContainer.style.display = "block";

    // get our browser's size
    browserWidth = document.documentElement.clientWidth;
    browserHeight = document.documentElement.clientHeight;

    // create each individual snowflake
    for (let i = 0; i < numberOfSnowflakes; i++) {
      // clone our original snowflake and add it to snowflakeContainer
      let snowflakeClone = originalSnowflake.cloneNode(true);
      snowflakeContainer.appendChild(snowflakeClone);

      // set our snowflake's initial position and related properties
      let initialXPos = getPosition(50, browserWidth);
      let initialYPos = getPosition(50, browserHeight);
      let speed = (5 + Math.random() * 40) * delta;

      // create our Snowflake object
      let snowflakeObject = new Snowflake(
        snowflakeClone,
        speed,
        initialXPos,
        initialYPos
      );
      snowflakes.push(snowflakeObject);
    }

    // remove the original snowflake because we no longer need it visible
    snowflakeContainer.removeChild(originalSnowflake);

    requestAnimationFrame(moveSnowflakes);
  }

  //
  // Responsible for moving each snowflake by calling its update function
  //
  let frames_per_second = 60;
  let frame_interval = 1000 / frames_per_second;

  let previousTime = performance.now();
  let delta = 1;

  function moveSnowflakes(currentTime) {
    delta = (currentTime - previousTime) / frame_interval;

    if (enableAnimations) {
      for (let i = 0; i < snowflakes.length; i++) {
        let snowflake = snowflakes[i];
        snowflake.update(delta);
      }
    }

    previousTime = currentTime;

    // Reset the position of all the snowflakes to a new value
    if (resetPosition) {
      browserWidth = document.documentElement.clientWidth;
      browserHeight = document.documentElement.clientHeight;

      for (let i = 0; i < snowflakes.length; i++) {
        let snowflake = snowflakes[i];

        snowflake.xPos = getPosition(50, browserWidth);
        snowflake.yPos = getPosition(50, browserHeight);
      }

      resetPosition = false;
    }

    requestAnimationFrame(moveSnowflakes);
  }

  //
  // This function returns a number between (maximum - offset) and (maximum + offset)
  //
  function getPosition(offset, size) {
    return Math.round(-1 * offset + Math.random() * (size + 2 * offset));
  }

  //
  // Trigger a reset of all the snowflakes' positions
  //
  function setResetFlag(e) {
    resetPosition = true;
  }