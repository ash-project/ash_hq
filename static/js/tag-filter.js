// Filters the blog's list of posts by tag. Without this script the filter stays hidden and every
// post is listed.
//
// Expects, inside [data-tag-filter]: a fieldset of radios named "tag" (the value "all" shows
// everything), rows with a space-separated data-tags, and a [data-tag-filter-status] live region
// to announce the result.

for (const container of document.querySelectorAll("[data-tag-filter]")) {
  const filter = container.querySelector("fieldset");
  const rows = [...container.querySelectorAll("[data-tags]")];
  const status = container.querySelector("[data-tag-filter-status]");

  filter.hidden = false;

  filter.addEventListener("change", (event) => {
    const tag = event.target.value;
    let shown = 0;

    for (const row of rows) {
      const matches = tag === "all" || row.dataset.tags.split(" ").includes(tag);
      row.hidden = !matches;
      if (matches) shown += 1;
    }

    const posts = shown === 1 ? "1 post" : `${shown} posts`;
    status.textContent = tag === "all" ? `Showing all ${posts}` : `Showing ${posts} tagged ${tag}`;
  });
}
