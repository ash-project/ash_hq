// The mobile menu toggle in the site header. Without this script the menu is always shown, so
// navigation never depends on JavaScript.

const header = document.querySelector("[data-site-header]");
const toggle = header?.querySelector("[aria-controls]");

if (toggle) {
  const setOpen = (open) => {
    toggle.setAttribute("aria-expanded", String(open));
    header.classList.toggle("site-header--open", open);
  };

  toggle.hidden = false;

  toggle.addEventListener("click", () => {
    setOpen(toggle.getAttribute("aria-expanded") !== "true");
  });

  // Escape closes the menu and returns focus to the toggle
  header.addEventListener("keydown", (event) => {
    if (event.key === "Escape" && toggle.getAttribute("aria-expanded") === "true") {
      setOpen(false);
      toggle.focus();
    }
  });

  // Widening past the breakpoint shows the full navigation, so reset the toggle
  matchMedia("(min-width: 861px)").addEventListener("change", (query) => {
    if (query.matches) setOpen(false);
  });
}
