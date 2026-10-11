// Splits a long list into pages (templates/components/paginated.html). Without this script the
// pagination stays hidden and the whole list shows.
//
// Inside [data-paginate]: the list (a <ul>), and a [data-pagination] nav with previous and next
// buttons, a button for each page, gaps, a page count for small screens, and a live region that
// announces each change.
//
// After a change, focus moves to the list, so the next Tab reaches its first item, and the list
// scrolls into view.

// Every page, up to seven; past that, the first, the last and those either side of the current one
const shownPages = (current, count) =>
  count <= 7 ? null : new Set([1, count, current - 1, current, current + 1]);

for (const container of document.querySelectorAll("[data-paginate]")) {
  const nav = container.querySelector("[data-pagination]");
  if (!nav) continue;

  const list = container.querySelector(":scope > ul");
  const items = [...list.children];
  const size = Number(container.dataset.pageSize);
  const count = Math.ceil(items.length / size);
  const previous = nav.querySelector("[data-page-previous]");
  const next = nav.querySelector("[data-page-next]");
  const pageButtons = [...nav.querySelectorAll("[data-page]")];
  const [firstGap, lastGap] = nav.querySelectorAll("[data-page-gap]");
  const pageCount = nav.querySelector("[data-page-count]");
  const status = nav.querySelector("[data-page-status]");
  let current = 1;

  // aria-disabled rather than disabled, so a step button keeps focus when it reaches the end
  const setDisabled = (button, disabled) => {
    if (disabled) button.setAttribute("aria-disabled", "true");
    else button.removeAttribute("aria-disabled");
  };

  const show = (page, { announce = true } = {}) => {
    current = page;
    items.forEach((item, i) => {
      item.hidden = Math.floor(i / size) + 1 !== page;
    });

    const shown = shownPages(page, count);
    pageButtons.forEach((button) => {
      const number = Number(button.dataset.page);
      button.parentElement.hidden = shown !== null && !shown.has(number);
      if (number === page) button.setAttribute("aria-current", "page");
      else button.removeAttribute("aria-current");
    });
    if (firstGap) firstGap.hidden = shown === null || page - 1 <= 2;
    if (lastGap) lastGap.hidden = shown === null || page + 1 >= count - 1;

    setDisabled(previous, page === 1);
    setDisabled(next, page === count);
    pageCount.textContent = `Page ${page} of ${count}`;
    if (announce) status.textContent = `Page ${page} of ${count}`;
  };

  const go = (page) => {
    if (page < 1 || page > count || page === current) return;
    show(page);
    list.focus();
  };

  list.tabIndex = -1;
  previous.addEventListener("click", () => go(current - 1));
  next.addEventListener("click", () => go(current + 1));
  pageButtons.forEach((button) => {
    button.addEventListener("click", () => go(Number(button.dataset.page)));
  });

  show(1, { announce: false });
  nav.hidden = false;
}
