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

Hooks.ColorTheme = {
  mounted() {
    this.handleEvent('set_theme', (payload) => {
      document.documentElement.classList.add(payload.theme);
      if(payload.theme === "dark") {
        document.documentElement.classList.remove("light");
      } else {
        document.documentElement.classList.remove("dark");
      };

      document.cookie = 'theme' + '=' + payload.theme + ';path=/';
    })
  }
}

Hooks.Docs = {
  mounted() {
    mermaid.init(".mermaid")
  }
}

Hooks.CmdK = {
  mounted() {
    window.addEventListener("keydown", (event) => {
      if(event.metaKey && event.key === "k") {
        document.getElementById("search-button").click()
      }
    })
    window.addEventListener("keydown", (event) => {
      if(event.key === "Escape") {
        document.getElementById("close-search").click()
      }
    })
    window.addEventListener("phx:close-search", (_event) => {
      document.getElementById("close-search").click()
    })
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
// window.addEventListener("js:noscroll-main", e =>  {
//   if(e.target.style.display === "none") {
//     document.getElementById("main-container").classList.add("overflow-hidden")
//   } else {
//     document.getElementById("main-container").classList.remove("overflow-hidden")
//   }
// })

window.addEventListener("phx:js:scroll-to", (e) => {
  const target = document.getElementById(e.detail.id);
  console.log(target);
  const boundary = document.getElementById(e.detail.boundary_id);
  scrollIntoView(target, { 
    behavior: 'smooth', 
    block: 'center',
    boundary: boundary
  });
});

window.addEventListener("phx:selected-versions", (e) => {
  const cookie = Object.keys(e.detail).map((key) => `${key}:${e.detail[key]}`).join(',');
  document.cookie = 'selected_versions' + '=' + cookie + ';path=/';
});

window.addEventListener("phx:selected-types", (e) => {
  console.log(e.detail);
  const cookie = e.detail.types.join(',');
  document.cookie = 'selected_types' + '=' + cookie + ';path=/';
});

// connect if there are any LiveViews on the page
liveSocket.connect()


// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

