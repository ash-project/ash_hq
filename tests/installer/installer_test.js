// Run with: deno test --allow-read tests/
//
// fixtures/ holds the scripts the Phoenix app served for the URLs in fixtures/manifest.txt,
// fetched from ash-hq.org before the rebuild. The edge function must match them exactly.

import handler from "../../netlify/edge-functions/installer.js";

const fixtures = new URL("./fixtures/", import.meta.url);

function get(path) {
  return handler(new Request(`https://ash-hq.org${path}`));
}

const manifest = await Deno.readTextFile(new URL("manifest.txt", fixtures));

for (const line of manifest.trim().split("\n")) {
  const [file, path] = line.split(" ");

  Deno.test(`${path} matches the Phoenix app`, async () => {
    const response = get(path);
    const expected = await Deno.readTextFile(new URL(file, fixtures));

    assertEquals(response.status, 200);
    assertEquals(response.headers.get("content-type"), "text/plain; charset=utf-8");
    assertEquals(await response.text(), expected);
  });
}

// Each tries to sneak `echo injected` into the script
const hostile = [
  ["/install/my_app%22%3Becho%20injected%3B%22", "a quote in the app name"],
  ["/install/my_app?with_args=$(echo%20injected)", "a command substitution in with_args"],
  ["/new/my_app?install=ash_postgres%3Becho%20injected", "a semicolon in a package"],
  ["/new/my_app?example=%60echo%20injected%60", "backticks in a value"],
  ["/new/my_app?example=a%22%3Becho%20injected%3B%22b", "a quote in a value"],
  ["/new/my_app?ex%3Becho%20injected%3Bample=true", "a semicolon in a parameter name"],
  ["/new/my_app?example=a%0Aecho%20injected", "a newline in a value"],
];

for (const [path, description] of hostile) {
  Deno.test(`refuses ${description}`, async () => {
    const response = get(path);
    const body = await response.text();

    assertEquals(response.status, 400);
    assert(body.startsWith("#!/bin/sh\n"), "the error is itself a script, safe to pipe into sh");
    assert(body.includes("exit 1"));
    assert(!body.includes("injected"), "the error doesn't echo the input back");
  });
}

Deno.test("only serves /new/:name and /install/:name", () => {
  assertEquals(get("/install/").status, 404);
  assertEquals(get("/install/my_app/extra").status, 404);
});

function assert(condition, message = "assertion failed") {
  if (!condition) throw new Error(message);
}

function assertEquals(actual, expected) {
  if (actual !== expected) {
    throw new Error(`expected ${JSON.stringify(expected)}\n     got ${JSON.stringify(actual)}`);
  }
}
