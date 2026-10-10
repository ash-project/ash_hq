// Run with: deno test --allow-read tests/
//
// Where the old site redirected these docs URLs, recorded from ash-hq.org before the rebuild. Where
// the old site rendered its home page at the URL itself, the edge function redirects to it.

import handler from "../../netlify/edge-functions/docs-redirect.js";

const home = "https://ash-hq.org/";

const recorded = [
  // Pages the old site rendered as its home page
  ["/docs/", home],
  ["/docs/ash/latest", home],
  ["/docs/foo/bar/baz", home],
  ["/docs/dsl/ash/latest", home],

  ["/docs/guides/ash/latest/tutorials/get-started", "https://hexdocs.pm/ash/get-started.html"],
  ["/docs/guides/ash_postgres/latest/tutorials/get-started-with-ash-postgres", "https://hexdocs.pm/ash_postgres/get-started-with-ash-postgres.html"],
  ["/docs/guides/ash/3.0.0/topics/actions/actions", "https://hexdocs.pm/ash/actions.html"],

  ["/docs/module/ash/latest/Ash.Resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/module/ash_postgres/latest/AshPostgres.DataLayer", "https://hexdocs.pm/ash_postgres/AshPostgres.DataLayer.html"],
  ["/docs/module/ash/latest/ash-resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/module/ash/latest/Nope.Module", home],
  ["/docs/module/ash_authentication_phoenix/latest/AshAuthentication.Phoenix.Router", "https://hexdocs.pm/ash_authentication_phoenix/AshAuthentication.Phoenix.Router.html"],

  ["/docs/dsl/Ash.Resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/dsl/AshPostgres.DataLayer", "https://hexdocs.pm/ash_postgres/AshPostgres.DataLayer.html"],
  ["/docs/dsl/ash-resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/dsl/ash/latest/ash-resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/dsl/ash/latest/Ash.Resource", "https://hexdocs.pm/ash/Ash.Resource.html"],
  ["/docs/dsl/AshAuthentication.Phoenix.Router", "https://hexdocs.pm/ash_authentication_phoenix/AshAuthentication.Phoenix.Router.html"],
];

// The old site sent every mix task to its home page: it failed to find them
const fixed = [
  ["/docs/mix_task/ash/latest/ash.codegen", "https://hexdocs.pm/ash/Mix.Tasks.Ash.Codegen.html"],
  ["/docs/mix_task/ash_postgres/latest/ash_postgres.generate_migrations", "https://hexdocs.pm/ash_postgres/Mix.Tasks.AshPostgres.GenerateMigrations.html"],
  ["/docs/mix_task/ash/latest/Mix.Tasks.Ash.Codegen", "https://hexdocs.pm/ash/Mix.Tasks.Ash.Codegen.html"],
];

for (const [path, expected] of [...recorded, ...fixed]) {
  Deno.test(`docs redirect: ${path}`, () => {
    const response = handler(new Request(`https://ash-hq.org${path}`));
    if (response.status !== 302) throw new Error(`expected a 302, got ${response.status}`);
    const location = response.headers.get("location");
    if (location !== expected) throw new Error(`expected ${expected}\n     got ${location}`);
  });
}
