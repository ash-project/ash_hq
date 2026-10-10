// Filters a list by what's typed into a text box, matching each item's text. Without this script
// the filter stays hidden and the whole list shows.
//
// Inside [data-filter-list]: a [data-filter] wrapper (hidden until this runs) around an input, a
// list whose items are filtered, a [data-filter-empty] message for no matches (hidden), and a
// [data-filter-status] live region to announce the result. data-filter-noun names the items, in
// the plural, for the announcement.

for (const container of document.querySelectorAll("[data-filter-list]")) {
  const filter = container.querySelector("[data-filter]");
  const input = filter.querySelector("input");
  const items = [...container.querySelectorAll("[data-filter-items] > li")];
  const empty = container.querySelector("[data-filter-empty]");
  const status = container.querySelector("[data-filter-status]");
  const noun = container.dataset.filterNoun ?? "items";
  // Match visible text only, not notes for screen readers like "(opens in a new tab)"
  const visibleText = (item) => {
    const copy = item.cloneNode(true);
    copy.querySelectorAll(".visually-hidden").forEach((hidden) => hidden.remove());
    return copy.textContent.toLowerCase();
  };
  const texts = items.map(visibleText);

  filter.hidden = false;

  input.addEventListener("input", () => {
    const query = input.value.trim().toLowerCase();
    let shown = 0;

    items.forEach((item, i) => {
      const matches = texts[i].includes(query);
      item.hidden = !matches;
      if (matches) shown += 1;
    });

    empty.hidden = shown > 0;
    status.textContent = query ? `${shown} of ${items.length} ${noun} match` : `Showing all ${items.length} ${noun}`;
  });
}
