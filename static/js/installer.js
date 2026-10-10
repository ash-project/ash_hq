// The Installer page's options: presets, features, the project name and mode. Everything it needs
// is in the data attributes of templates/installer.html, from data/installer.toml; the command
// itself is built by installer-command.js.

import { buildCommand, selection } from "./installer-command.js";

const root = document.querySelector("[data-installer]");

if (root) {
  const nameInput = root.querySelector("[data-installer-name]");
  const modeGroup = root.querySelector("[data-installer-mode]");
  const elixirOption = root.querySelector("[data-installer-elixir-option]");
  const elixirCheckbox = root.querySelector("[data-installer-elixir]");
  const commandEl = root.querySelector("[data-installer-command]");
  const countEl = root.querySelector("[data-installer-count]");
  const copyButton = root.querySelector("[data-installer-copy]");
  const copyLabel = copyButton.querySelector("span");
  const status = root.querySelector("[data-installer-status]");
  const docs = root.querySelector("[data-installer-docs]");
  const installOrder = root.dataset.installOrder.split(" ");

  const presetButtons = [...root.querySelectorAll("[data-preset]")];
  const featureButtons = [...root.querySelectorAll("[data-feature]")];
  const list = (value) => (value ? value.split(" ") : []);

  const features = Object.fromEntries(
    featureButtons.map((button) => [
      button.dataset.feature,
      {
        button,
        label: button.dataset.label,
        adds: list(button.dataset.adds),
        args: button.dataset.args ? button.dataset.args.split("|") : [],
        requires: list(button.dataset.requires),
        checked: false,
      },
    ]),
  );

  let mode = "new";
  let preset = null;

  // A random name to start with, as the Phoenix app did
  const names = root.dataset.appNames.split("|");
  nameInput.value = names[Math.floor(Math.random() * names.length)];

  function render() {
    // A feature another picked feature requires is selected too, and can't be turned off
    for (const [key, feature] of Object.entries(features)) {
      const requiredBy = Object.values(features)
        .filter((other) => other.checked && other.requires.includes(key))
        .map((other) => other.label);
      const note = feature.button.parentElement.querySelector("[data-locked-note]");

      feature.button.setAttribute("aria-pressed", String(feature.checked || requiredBy.length > 0));
      if (requiredBy.length > 0) {
        feature.button.setAttribute("aria-disabled", "true");
        if (note) note.textContent = `Required by ${requiredBy.join(", ")}.`;
      } else {
        feature.button.removeAttribute("aria-disabled");
        if (note) note.textContent = "";
      }
    }

    for (const button of presetButtons) {
      button.setAttribute("aria-pressed", String(button.dataset.preset === preset));
    }

    const selected = selection(features, installOrder);
    commandEl.textContent = buildCommand({
      features,
      installOrder,
      mode,
      installElixir: elixirCheckbox.checked,
      appName: nameInput.value,
      phoenixVersion: root.dataset.phoenixVersion,
    });
    countEl.textContent = `· ${selected.size} ${selected.size === 1 ? "feature" : "features"}`;
    copyLabel.textContent = "Copy Command";

    // Docs links and setup notes for the features picked, each once
    const shown = new Set();
    for (const item of docs.querySelectorAll("[data-for]")) {
      const id = `${item.tagName}:${item.querySelector("a").href}`;
      item.hidden = !selected.has(item.dataset.for) || shown.has(id);
      if (!item.hidden) shown.add(id);
    }
    docs.hidden = shown.size === 0;
  }

  // Picking a preset replaces the features picked; picking it again clears them
  function choosePreset(id) {
    for (const feature of Object.values(features)) feature.checked = false;
    preset = preset === id ? null : id;
    if (preset) {
      const button = presetButtons.find((b) => b.dataset.preset === preset);
      for (const key of list(button.dataset.features)) features[key].checked = true;
    }
    render();
  }

  // Changing a feature means the preset no longer describes what's picked
  function toggleFeature(key) {
    const feature = features[key];
    if (feature.button.getAttribute("aria-disabled") === "true") return;
    feature.checked = !feature.checked;
    preset = null;
    render();
  }

  // Existing apps already have their web layer, so Phoenix and the LiveView preset don't apply,
  // and Elixir is already installed
  function setMode(value) {
    mode = value;
    const existing = mode === "existing";
    const liveView = presetButtons.find((b) => b.dataset.preset === "live_view");

    elixirOption.hidden = existing;
    features.phoenix.button.parentElement.hidden = existing;
    liveView.parentElement.hidden = existing;
    if (existing) {
      features.phoenix.checked = false;
      if (preset === "live_view") return choosePreset("graphql");
    }
    render();
  }

  presetButtons.forEach((button) => button.addEventListener("click", () => choosePreset(button.dataset.preset)));
  featureButtons.forEach((button) => button.addEventListener("click", () => toggleFeature(button.dataset.feature)));
  modeGroup.addEventListener("change", (event) => setMode(event.target.value));
  elixirCheckbox.addEventListener("change", render);
  nameInput.addEventListener("input", render);

  copyButton.addEventListener("click", async () => {
    await navigator.clipboard.writeText(commandEl.textContent);
    copyLabel.textContent = "Copied";
    status.textContent = "Copied the install command to the clipboard";
  });

  // Tooltips close with Escape, and stay closed until the pointer or focus leaves
  for (const chip of root.querySelectorAll(".option-chip")) {
    const reopen = () => chip.classList.remove("option-chip--tip-dismissed");
    chip.addEventListener("keydown", (event) => {
      if (event.key === "Escape") chip.classList.add("option-chip--tip-dismissed");
    });
    chip.addEventListener("mouseleave", reopen);
    chip.addEventListener("focusout", reopen);
  }

  // Ready: show the options, and start with the first preset
  root.querySelector("[data-installer-options]").hidden = false;
  root.querySelector("[data-installer-fallback]").hidden = true;
  countEl.hidden = false;
  copyButton.hidden = false;
  choosePreset(presetButtons[0].dataset.preset);
}
