// A section whose visual stays put while its steps scroll by. Each step names the states
// it moves the visual through, `data-states="before after"`, and when a step comes into
// view the visual plays through them: the first straight away, so it's clear what's about
// to change, then the rest in turn.
//
// On a wide screen the visual sits beside the steps, and a step comes into view when it
// reaches the middle of the screen. On a narrow one the visual is pinned above them, so a
// step comes into view a little way into what's left of the screen below it.

const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)")
const stacked = window.matchMedia("(max-width: 1023px)")

export function scrolly(section, view, states) {
  const steps = [...section.querySelectorAll("[data-states]")]
  const stateNames = (step) => step.dataset.states.split(/\s+/)
  const replayButton = section.querySelector("[data-replay]")
  const visual = section.querySelector(".scrolly-visual")
  let active = -1
  let timers = []

  const stop = () => {
    timers.forEach(clearTimeout)
    timers = []
  }

  const play = (index, {from = 0} = {}) => {
    stop()
    const names = stateNames(steps[index])

    if (reducedMotion.matches) {
      view.show(states[names.at(-1)], {animate: false})
      return
    }

    view.show(states[names[from]], {animate: from === 0 && active !== -1})
    let delay = 0

    names.slice(from + 1).forEach((name, offset) => {
      delay += offset === 0 ? 550 : 1400
      timers.push(setTimeout(() => view.show(states[name]), delay))
    })
  }

  const activate = (index) => {
    if (index === active) return
    steps.forEach((step, i) => step.classList.toggle("is-active", i === index))

    // Scrolling back up shows how a step left things, rather than playing it again.
    if (index < active) {
      stop()
      view.show(states[stateNames(steps[index]).at(-1)])
    } else {
      play(index)
    }

    active = index
  }

  // Where a step's top has to reach to come into view.
  const line = () => {
    if (!stacked.matches) return window.innerHeight / 2
    const below = visual.getBoundingClientRect().bottom
    return below + (window.innerHeight - below) * 0.35
  }

  // The step is the last one whose top has passed the line, so scrolling quickly past one
  // still lands on the right one.
  let frame = null
  const onScroll = () => {
    if (frame) return
    frame = requestAnimationFrame(() => {
      frame = null
      const at = line()
      let index = -1
      steps.forEach((step, i) => {
        if (step.getBoundingClientRect().top < at) index = i
      })
      if (index >= 0) activate(index)
    })
  }

  // Steps snap to just below the visual when it's pinned above them, so it's kept up to date
  // on how tall the visual is.
  new ResizeObserver(() => {
    section.style.setProperty("--visual-height", `${visual.offsetHeight}px`)
  }).observe(visual)

  window.addEventListener("scroll", onScroll, {passive: true})
  window.addEventListener("resize", onScroll)
  replayButton?.addEventListener("click", () => {
    if (active >= 0) {
      view.show(states[stateNames(steps[active])[0]], {animate: false})
      requestAnimationFrame(() => play(active, {from: 0}))
    }
  })

  view.show(states[stateNames(steps[0])[0]], {animate: false})
}
