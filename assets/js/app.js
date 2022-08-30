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
import scrollIntoView from 'smooth-scroll-into-view-if-needed'

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import mermaid from "mermaid"
mermaid.init(".mermaid")

const Hooks = {};

const configuredThemeRow = document.cookie
  .split('; ')
  .find(row => row.startsWith('theme='))


if (!configuredThemeRow) {
  let theme;
  if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
    theme = "dark";
  } else {
    theme = "light";
  }
}

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', event => {
  const configuredThemeRow = document.cookie
    .split('; ')
    .find(row => row.startsWith('theme='))

  if(!configuredThemeRow || configuredThemeRow === "theme=system") {
    setTheme("system")
  } else {
    if(configuredThemeRow === "theme=dark") {
      setTheme("dark")
    } else if (configuredThemeRow === "theme=light") {
      setTheme("light")
    } else {
      setTheme("system")
    }
  }
});

function setTheme(theme) {
  console.log(theme)
  let setTheme;
  if(theme == "system") {
    if (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) {
      setTheme = "dark";
    } else {
      setTheme = "light";
    }
  } else {
    setTheme = theme;
  }

  document.documentElement.classList.add(setTheme);

  if(setTheme === "dark") {
    document.documentElement.classList.remove("light");
  } else {
    document.documentElement.classList.remove("dark");
  };

  document.cookie = 'theme' + '=' + theme + ';path=/';
}

Hooks.ColorTheme = {
  mounted() {
    this.handleEvent('set_theme', (payload) => {
      setTheme(payload.theme)
    })
  }
}

Hooks.Docs = {
  mounted() {
    mermaid.init(".mermaid")
  }
}

function onScrollChange() {
  const docs = document.getElementById("docs-window");
  if(docs) {
    const scrollTop = docs.scrollTop;
    const topEl = Array.from(document.getElementsByClassName("nav-anchor")).filter((el) => {
      return (el.offsetTop + el.clientHeight) >= scrollTop;
    })[0];
    let hash;
    if(window.location.hash){
      hash = window.location.hash.substring(1);
    }
    if(topEl && topEl.id !== hash){
      history.replaceState(null, null, `#${topEl.id}`)
      window.location.hash = topEl.id;
      const newTarget = document.getElementById(`right-nav-${topEl.id}`);
      Array.from(document.getElementsByClassName("currently-active-nav")).forEach((el) => {
        el.classList.remove("currently-active-nav");
        el.classList.remove("text-orange-600");
        el.classList.remove("dark:text-orange-400");
      }) 
      if(newTarget) {
        newTarget.classList.add("dark:text-orange-400");
        newTarget.classList.add("text-orange-600");
        newTarget.classList.add("currently-active-nav")
      }
    }
  }
}

function handleHashChange(clear) {
  if (window.location.hash) {
    const el = document.getElementById("right-nav-" + window.location.hash.substring(1))
    if(el) {
      if (clear) {
        Array.from(document.getElementsByClassName("currently-active-nav")).forEach((el) => {
          el.classList.remove("currently-active-nav");
          el.classList.remove("text-orange-600");
          el.classList.remove("dark:text-orange-400");
        }) 
      }
      el.classList.add("dark:text-orange-400");
      el.classList.add("text-orange-600");
      el.classList.add("currently-active-nav")
      scrollIntoView(el, {
        behavior: 'smooth', 
        block: 'center'
      })
    }
  }
}

Hooks.RightNav = {
  mounted() {
    handleHashChange(false);
    const docs = document.getElementById("docs-window");
    if (docs) {
      docs.addEventListener("scroll", () => onScrollChange())
      if(this.interval) {
        clearInterval(this.interval)
      };

      this.interval = setInterval(() => handleHashChange(true), 100);
    }
  },
  destroyed() {
    if(this.interval) {
      clearInterval(this.interval)
    }
  }
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {
  params: {_csrf_token: csrfToken}, 
  hooks: Hooks,
  metadata: {
    keydown: (e) => {
      return {
        key: e.key,
        metaKey: e.metaKey
      }
    }
  }
});

// Show progress bar on live navigation and form submits. Only displays if still
// loading after 120 msec
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

let topBarScheduled = undefined;
window.addEventListener("phx:page-loading-start", () => {
  if(!topBarScheduled) {
    topBarScheduled = setTimeout(() => topbar.show(), 120);
  };
});
window.addEventListener("phx:page-loading-stop", () => {
  clearTimeout(topBarScheduled);
  topBarScheduled = undefined;
  topbar.hide();
});


window.addEventListener("js:focus", e => e.target.focus())


window.addEventListener("phx:js:scroll-to", (e) => {
  const target = document.getElementById(e.detail.id);
  const boundary = document.getElementById(e.detail.boundary_id);
  scrollIntoView(target, { 
    behavior: 'smooth', 
    block: 'center',
    boundary: boundary
  });
});

window.addEventListener("phx:sidebar-state", (e) => {
  const cookie = Object.keys(e.detail).map((key) => `${key}:${e.detail[key]}`).join(',');
  document.cookie = 'sidebar_state' + '=' + cookie + ';path=/';
})


let scrolled = false;

window.addEventListener("phx:page-loading-start", () => {
  scrolled = false;
})

window.addEventListener("phx:page-loading-stop", ({detail}) => {
  if(detail.kind === "initial" && window.location.hash && !scrolled){
    let hashEl = document.getElementById(window.location.hash.substring(1));
    console.log(hashEl);
    hashEl && hashEl.scrollIntoView();
    scrolled = true;
  }
  topbar.hide();
})

window.addEventListener("phx:selected-versions", (e) => {
  const cookie = Object.keys(e.detail).map((key) => `${key}:${e.detail[key]}`).join(',');
  document.cookie = 'selected_versions' + '=' + cookie + ';path=/';
});

window.addEventListener("phx:selected-types", (e) => {
  const cookie = e.detail.types.join(',');
  document.cookie = 'selected_types' + '=' + cookie + ';path=/';
});

window.addEventListener("keydown", (event) => {
  if((event.metaKey || event.ctrlKey) && event.key === "k") {
    document.getElementById("search-button").click()
    event.preventDefault();
  }
})
window.addEventListener("keydown", (event) => {
  if(event.key === "Escape") {
    document.getElementById("close-search").click()
    event.preventDefault();
  }
})
window.addEventListener("phx:close-search", (event) => {
  document.getElementById("close-search").click()
  event.preventDefault();
})

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
liveSocket.disableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

