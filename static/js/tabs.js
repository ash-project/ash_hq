// Turns [data-tabs] containers into tabs, following the WAI-ARIA tabs pattern: each panel's
// [data-tab-label] heading becomes a tab, arrow keys, Home and End move between tabs, and Tab moves
// into the panel. Without this script the panels are shown in turn, under their headings.
//
// The selected tab is kept in the URL's hash (the panel's id), so it survives going back to the
// page and can be linked to. It replaces the history entry rather than adding one, so Back leaves
// the page instead of stepping through tabs.

for (const container of document.querySelectorAll("[data-tabs]")) {
  const panels = [...container.querySelectorAll(":scope > .tabs__panel")];
  const list = document.createElement("div");
  list.className = "tabs__list";
  list.setAttribute("role", "tablist");

  const tabs = panels.map((panel) => {
    const label = panel.querySelector("[data-tab-label]");
    const tab = document.createElement("button");
    tab.type = "button";
    tab.className = "tabs__tab";
    tab.id = `${panel.id}-tab`;
    tab.textContent = label.textContent;
    tab.setAttribute("role", "tab");
    tab.setAttribute("aria-controls", panel.id);

    // The tab now names the panel, so its heading would only repeat it
    label.hidden = true;
    panel.setAttribute("role", "tabpanel");
    panel.setAttribute("aria-labelledby", tab.id);
    panel.tabIndex = 0;

    list.append(tab);
    return tab;
  });

  const select = (index, { focus = false, updateUrl = true } = {}) => {
    tabs.forEach((tab, i) => {
      const selected = i === index;
      tab.setAttribute("aria-selected", String(selected));
      tab.tabIndex = selected ? 0 : -1;
      panels[i].hidden = !selected;
    });
    if (focus) tabs[index].focus();
    if (updateUrl) history.replaceState(history.state, "", `#${panels[index].id}`);
  };

  // The tab named by the URL's hash, if any
  const fromHash = () => panels.findIndex((panel) => `#${panel.id}` === location.hash);

  list.addEventListener("click", (event) => {
    const index = tabs.indexOf(event.target.closest("[role=tab]"));
    if (index >= 0) select(index);
  });

  addEventListener("hashchange", () => {
    const index = fromHash();
    if (index >= 0) select(index, { updateUrl: false });
  });

  list.addEventListener("keydown", (event) => {
    const current = tabs.indexOf(document.activeElement);
    const last = tabs.length - 1;
    const next = {
      ArrowRight: current === last ? 0 : current + 1,
      ArrowLeft: current === 0 ? last : current - 1,
      Home: 0,
      End: last,
    }[event.key];

    if (next !== undefined) {
      event.preventDefault();
      select(next, { focus: true });
    }
  });

  container.prepend(list);
  container.classList.add("tabs--enhanced");
  select(Math.max(fromHash(), 0), { updateUrl: false });
}
