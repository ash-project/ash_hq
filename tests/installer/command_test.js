// Run with: deno test --allow-read tests/
//
// command_fixtures.json holds the commands the Phoenix app's installer generated for a set of
// scenarios (its `setUrl`, run against main's app.js before the rebuild). The Installer page must
// generate the same commands from data/installer.toml.

import { parse } from "jsr:@std/toml@1";
import { buildCommand } from "../../static/js/installer-command.js";

const data = parse(await Deno.readTextFile(new URL("../../data/installer.toml", import.meta.url)));
const fixtures = JSON.parse(await Deno.readTextFile(new URL("command_fixtures.json", import.meta.url)));
const installOrder = data.features.map((feature) => feature.key);

function featuresWith(checked) {
  return Object.fromEntries(
    data.features.map((feature) => [
      feature.key,
      {
        adds: feature.adds,
        args: feature.args ?? [],
        requires: feature.requires ?? [],
        checked: checked.includes(feature.key),
      },
    ]),
  );
}

for (const fixture of fixtures) {
  Deno.test(`installer command: ${fixture.name}`, () => {
    const command = buildCommand({
      features: featuresWith(fixture.checked),
      installOrder,
      mode: fixture.mode,
      installElixir: fixture.installElixir,
      appName: fixture.appName,
      phoenixVersion: fixture.phoenixVersion,
    });

    if (command !== fixture.expected) {
      throw new Error(`expected:\n${fixture.expected}\n\ngot:\n${command}`);
    }
  });
}

Deno.test("every preset's features exist", () => {
  for (const preset of data.presets) {
    for (const key of preset.features) {
      if (!installOrder.includes(key)) throw new Error(`${preset.id} has an unknown feature: ${key}`);
    }
  }
});
