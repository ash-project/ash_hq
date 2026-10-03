// A call to an action gaining its options as you scroll past: who's running it, whose data
// it runs against, and, new with temporal resources, when it happens.

export function reveal(section) {
  const lines = [...section.querySelectorAll("[data-option]")]
  const last = lines.length
  section.classList.add("is-ready")

  let frame = null
  const update = () => {
    frame = null
    const rect = section.getBoundingClientRect()
    const progress = Math.min(Math.max(-rect.top / (rect.height - window.innerHeight), 0), 1)

    // Each option has its own stretch of the scroll, leaving the last for the new one to land.
    const shown = Math.min(Math.floor(progress * (last + 1.5)), last)

    for (const line of lines) {
      const option = Number(line.dataset.option)
      line.classList.toggle("is-shown", option <= shown)
      line.classList.toggle("is-current", option === shown)
    }

    section.classList.toggle("is-revealed", progress > (last + 0.5) / (last + 1.5))
  }

  const schedule = () => {
    if (!frame) frame = requestAnimationFrame(update)
  }

  window.addEventListener("scroll", schedule, {passive: true})
  window.addEventListener("resize", schedule)
  update()
}
