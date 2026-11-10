// Links the lines of the MCP post's tool figure (templates/components/tool-derivation.html).
// Pointing at a line highlights the lines it pairs with on both sides and, when the sides are next
// to each other, draws lines between them. Without this script, the numbers in the gutters pair
// the lines up.

const SVG = "http://www.w3.org/2000/svg";

for (const view of document.querySelectorAll("[data-tool-derivation] [data-view]")) {
  const pair = view.querySelector(".code-pair");
  const svg = view.querySelector(".tool-derivation__links");
  const [left, right] = view.querySelectorAll(".code-pair__pane");
  const lines = [...view.querySelectorAll(".code-line[data-link]")];
  let active = null;

  // Runs of consecutive lines in a pane that belong to a pair
  const runs = (pane, link) => {
    const found = [];
    let run = null;
    for (const line of pane.querySelectorAll(".code-line")) {
      if (line.dataset.link !== link) {
        run = null;
      } else if (run) {
        run.push(line);
      } else {
        found.push((run = [line]));
      }
    }
    return found;
  };

  const shape = (name, attributes) => {
    const element = document.createElementNS(SVG, name);
    for (const [attribute, value] of Object.entries(attributes)) element.setAttribute(attribute, value);
    return element;
  };

  const draw = () => {
    svg.replaceChildren();
    if (!active || !pair.offsetParent) return;

    const box = pair.getBoundingClientRect();
    const from = left.getBoundingClientRect();
    const to = right.getBoundingClientRect();
    // Stacked, on smaller screens: the highlighting is enough
    if (from.right >= to.left) return;

    const middle = (run) => {
      const top = run[0].getBoundingClientRect().top;
      const bottom = run.at(-1).getBoundingClientRect().bottom;
      return (top + bottom) / 2 - box.top;
    };

    const x1 = from.right - box.left;
    const x2 = to.left - box.left;
    const bend = (x2 - x1) / 2;

    for (const y1 of runs(left, active).map(middle)) {
      for (const y2 of runs(right, active).map(middle)) {
        svg.append(
          shape("path", { d: `M${x1} ${y1} C${x1 + bend} ${y1} ${x2 - bend} ${y2} ${x2} ${y2}` }),
          shape("circle", { cx: x1, cy: y1, r: 3 }),
          shape("circle", { cx: x2, cy: y2, r: 3 }),
        );
      }
    }
  };

  const show = (link) => {
    active = link;
    view.classList.toggle("is-linking", Boolean(link));
    for (const line of lines) line.classList.toggle("is-active", line.dataset.link === link);
    draw();
  };

  for (const line of lines) {
    line.addEventListener("pointerenter", () => show(line.dataset.link));
    line.addEventListener("pointerleave", () => show(null));
  }

  // Redraw when the layout changes: the window's size, fonts loading, or switching tools
  new ResizeObserver(draw).observe(pair);
}
