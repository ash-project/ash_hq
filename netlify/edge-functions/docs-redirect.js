// Redirects the old ash-hq.org docs URLs to hexdocs.pm, where the docs moved. Old links are all
// over forums, blogs and READMEs.
//
//   /docs/guides/:library/:version/…/:guide       → hexdocs.pm/:library/:guide.html
//   /docs/module/:library/:version/:module        → the module's page
//   /docs/dsl/:module, /docs/dsl/…/…/:module      → the module's page
//   /docs/mix_task/:library/:version/:task        → the mix task's page
//   anything else under /docs                     → the home page
//
// Modules and mix tasks are looked up in data/doc-modules.json (scripts/fetch-doc-modules.sh), by
// name ("Ash.Resource") or by the lowercased, dashed form the old site used ("ash-resource"). One
// that isn't found goes to the home page, as on the old site.
//
// This matches the old site's redirects (tests/docs-redirect/), except for mix tasks: the old site
// failed to find them, sending every one to the home page.

import modules from "../../data/doc-modules.json" with { type: "json" };

export const config = { path: ["/docs", "/docs/*"], method: ["GET", "HEAD"] };

export default function handler(request) {
  const url = new URL(request.url);
  const segments = url.pathname.split("/").filter(Boolean).slice(1).map(decodeURIComponent);
  return redirect(destination(segments) ?? new URL("/", url).href);
}

// Where an old docs URL's path (without "docs") now lives, if anywhere
export function destination([kind, ...rest]) {
  switch (kind) {
    case "guides":
      // library, version, then the guide's path: only its last part names the page now
      return rest.length >= 3 ? `https://hexdocs.pm/${rest[0]}/${rest.at(-1)}.html` : null;
    case "module":
    case "mix_task":
      return rest.length === 3 ? docsPage(rest[2]) : null;
    case "dsl":
      // Either a module on its own, or library, version and module
      if (rest.length === 1) return docsPage(rest[0]);
      if (rest.length === 3) return docsPage(rest[2]);
      return null;
    default:
      return null;
  }
}

function docsPage(name) {
  const page = modules[name] ?? modules[sanitize(name)];
  return page ? `https://hexdocs.pm/${page}.html` : null;
}

// How the old site turned names into URLs
function sanitize(name) {
  return name.toLowerCase().replace(/[^a-z0-9_]/g, "-");
}

function redirect(location) {
  return new Response(null, { status: 302, headers: { location } });
}
