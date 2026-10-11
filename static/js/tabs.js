// Turns [data-tabs] containers into tabs, following the WAI-ARIA tabs pattern: each panel's
// [data-tab-label] heading becomes a tab, arrow keys, Home and End move between tabs, and Tab moves
// into the panel. Without this script the panels are shown in turn, under their headings.
//
// data-tabs-orientation="vertical" makes a vertical tab list, which up and down arrows also move
// through. A heading with data-tab-keep-label stays visible; others are hidden, as the tab names
// the panel. Buttons in a panel with data-tab-prev or data-tab-next step through the tabs.
//
// The selected tab is kept in the URL's hash (the panel's id), so it survives going back to the
// page and can be linked to. It replaces the history entry rather than adding one, so Back leaves
// the page instead of stepping through tabs. Scrolling past the tabs, or back up nearer the top of
// the page than to them, clears the hash, so a reload or a shared link doesn't jump back to them,
// and scrolling back puts it back.

const reduceMotion = matchMedia("(prefers-reduced-motion: reduce)");

for (const container of document.querySelectorAll("[data-tabs]")) {
  const panels = [...container.querySelectorAll(":scope > .tabs__panel")];
  const vertical = container.dataset.tabsOrientation === "vertical";
  const list = document.createElement("div");
  list.className = "tabs__list";
  list.setAttribute("role", "tablist");
  if (vertical) list.setAttribute("aria-orientation", "vertical");

  const tabs = panels.map((panel) => {
    const label = panel.querySelector("[data-tab-label]");
    const tab = document.createElement("button");
    tab.type = "button";
    tab.className = "tabs__tab";
    tab.id = `${panel.id}-tab`;
    tab.textContent = label.textContent;
    tab.setAttribute("role", "tab");
    tab.setAttribute("aria-controls", panel.id);

    if (!("tabKeepLabel" in label.dataset)) label.hidden = true;
    panel.setAttribute("role", "tabpanel");
    panel.setAttribute("aria-labelledby", tab.id);
    panel.tabIndex = 0;

    list.append(tab);
    return tab;
  });

  let current = 0;

  const select = (index, { focus = false, updateUrl = true, reveal = false } = {}) => {
    current = index;
    tabs.forEach((tab, i) => {
      const selected = i === index;
      tab.setAttribute("aria-selected", String(selected));
      tab.tabIndex = selected ? 0 : -1;
      panels[i].hidden = !selected;
    });
    if (focus) tabs[index].focus();
    if (updateUrl) history.replaceState(history.state, "", `#${panels[index].id}`);

    // A sticky list of steps stays in view beside a long panel, and buttons can be at its bottom,
    // so the new panel's top can be scrolled off: scroll back up to it, clear of the header (the
    // page's scroll-padding-top). Smoothly, unless the reader prefers reduced motion.
    const clear = parseFloat(getComputedStyle(document.documentElement).scrollPaddingTop) || 0;
    if (reveal && panels[index].getBoundingClientRect().top < clear) {
      panels[index].scrollIntoView({ behavior: reduceMotion.matches ? "auto" : "smooth" });
    }
  };

  // The tab named by the URL's hash, if any
  const fromHash = () => panels.findIndex((panel) => `#${panel.id}` === location.hash);

  list.addEventListener("click", (event) => {
    const index = tabs.indexOf(event.target.closest("[role=tab]"));
    if (index >= 0) select(index, { reveal: true });
  });

  addEventListener("hashchange", () => {
    const index = fromHash();
    if (index >= 0) select(index, { updateUrl: false });
  });

  list.addEventListener("keydown", (event) => {
    const focused = tabs.indexOf(document.activeElement);
    const last = tabs.length - 1;
    const forward = focused === last ? 0 : focused + 1;
    const back = focused === 0 ? last : focused - 1;
    const next = {
      ArrowRight: forward,
      ArrowLeft: back,
      ...(vertical && { ArrowDown: forward, ArrowUp: back }),
      Home: 0,
      End: last,
    }[event.key];

    if (next !== undefined) {
      event.preventDefault();
      select(next, { focus: true, reveal: true });
    }
  });

  // Previous and next buttons, disabled at the ends; a panel can have them at its top and its
  // bottom. Pressing one shows the new panel from its top, and moves focus to the first of the
  // same button in it, as the one pressed is hidden with its panel, or to the panel at either end.
  panels.forEach((panel, i) => {
    for (const [selector, step] of [["[data-tab-prev]", -1], ["[data-tab-next]", 1]]) {
      for (const button of panel.querySelectorAll(selector)) {
        button.hidden = false;
        button.disabled = !panels[i + step];
        button.addEventListener("click", () => {
          select(current + step, { reveal: true });
          const same = panels[current].querySelector(selector);
          (same && !same.disabled ? same : panels[current]).focus({ preventScroll: true });
        });
      }
    }
  });

  // The hash is kept while the tabs are in view and the page is scrolled at least halfway from its
  // top to theirs, and cleared otherwise. Only once that's been the case, so the hash isn't cleared
  // before the browser scrolls to it, and only the hash this script set.
  let seen = false;
  let cleared = false;
  let pending = false;
  const updateHash = () => {
    pending = false;
    const { top, bottom } = container.getBoundingClientRect();
    const inView = top < innerHeight && bottom > 0;
    if (inView && scrollY >= (top + scrollY) / 2) {
      seen = true;
      if (cleared) {
        cleared = false;
        history.replaceState(history.state, "", `#${panels[current].id}`);
      }
    } else if (seen && fromHash() >= 0) {
      cleared = true;
      history.replaceState(history.state, "", location.pathname + location.search);
    }
  };
  const scheduleUpdate = () => {
    if (pending) return;
    pending = true;
    requestAnimationFrame(updateHash);
  };
  addEventListener("scroll", scheduleUpdate, { passive: true });
  scheduleUpdate();

  container.prepend(list);
  container.classList.add("tabs--enhanced");
  select(Math.max(fromHash(), 0), { updateUrl: false });
}
