// A small canvas that three people have been painting for the last hour, and what each
// part of the tour does to it. Everything shown is worked out from the paints, so the
// canvas, the leaderboard and a pixel's history always agree. Times are minutes past
// 09:00, and it's 09:45 now.

const COLORS = {pink: "#FF99AA", yellow: "#FFD635", green: "#00A368", blue: "#2450A4"}
const NOW = 45
const HOUR = 60
const SIZE = 6
const PAINTERS = {alice: "Alice", bob: "Bob", carol: "Carol"}

const paint = (id, x, y, color, painter, at) => ({id, cell: `${x},${y}`, color, painter, at})

const PAINTS = [
  paint(1, 1, 1, "blue", "alice", 5),
  paint(2, 2, 1, "blue", "bob", 10),
  paint(3, 1, 2, "yellow", "carol", 15),
  paint(4, 2, 2, "blue", "alice", 20),
  paint(5, 1, 1, "pink", "bob", 30),
  paint(6, 3, 3, "green", "alice", 40),
  paint(7, 4, 4, "blue", "carol", 42),
]

const NOW_PAINT = paint(8, 4, 1, "blue", "alice", NOW)
const PAST_PAINT = paint(9, 0, 4, "yellow", "carol", 12)
const FUTURE_PAINT = paint(10, 4, 1, "pink", "bob", 50)
const ALL = [...PAINTS, NOW_PAINT, PAST_PAINT, FUTURE_PAINT]

// What each step shows. A step of the article moves through a few of these in turn.
export const STATES = {
  start: {paints: PAINTS, marker: NOW},
  written: {paints: [...PAINTS, NOW_PAINT], marker: NOW},
  past: {paints: [...PAINTS, NOW_PAINT, PAST_PAINT], marker: NOW, ripple: [12, NOW]},
  future: {paints: ALL, marker: NOW},
  read: {paints: ALL, marker: 25},
  count: {paints: ALL, marker: 25, count: "blue"},
  painters: {paints: ALL, marker: 25, painters: true},
  leadersPast: {paints: ALL, marker: 25, leaderboard: true},
  leadersNow: {paints: ALL, marker: NOW, leaderboard: true},
  activePast: {paints: ALL, marker: 25, leaderboard: true, active: 10},
  activeNow: {paints: ALL, marker: NOW, leaderboard: true, active: 10},
  historyNow: {paints: ALL, marker: NOW, history: "1,1"},
  historyPast: {paints: ALL, marker: 25, history: "1,1"},
}

const clock = (minutes) =>
  `${String(9 + Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`

const position = (minutes) => `${(minutes * 100) / HOUR}%`
const fill = (color) => (color ? COLORS[color] : "rgb(255 255 255 / 0.08)")

// Each cell's latest paint up to a moment.
function canvasAt(paints, moment) {
  const canvas = new Map()
  ;[...paints].filter((p) => p.at <= moment).sort((a, b) => a.at - b.at).forEach((p) => canvas.set(p.cell, p))
  return canvas
}

function leaderboard(canvas, state) {
  const owned = {}
  for (const p of canvas.values()) owned[p.painter] = (owned[p.painter] || 0) + 1
  const most = Math.max(1, ...Object.values(owned))

  return Object.entries(PAINTERS).map(([painter, name]) => ({
    painter,
    name,
    count: owned[painter] || 0,
    width: ((owned[painter] || 0) * 100) / most,
    active:
      state.active !== undefined &&
      [...canvas.values()].some((p) => p.painter === painter && p.at > state.marker - state.active),
  }))
}

function versions(state) {
  const painted = state.paints
    .filter((p) => p.cell === state.history && p.at <= state.marker)
    .sort((a, b) => a.at - b.at)
    .map((p) => ({color: p.color, by: PAINTERS[p.painter], at: p.at}))

  return [{color: null, by: "", at: 0}, ...painted]
}

const element = (tag, className, parent) => {
  const el = document.createElement(tag)
  if (className) el.className = className
  if (parent) parent.appendChild(el)
  return el
}

// Restarts a CSS animation on an element.
function replay(el, className) {
  el.classList.remove(className)
  void el.offsetWidth
  el.classList.add(className)
}

export class TourView {
  constructor(root) {
    this.root = root
    root.classList.add("tour")

    this.caption = element("p", "visual-caption", root)

    const stage = element("div", "tour-stage", root)
    const canvas = element("div", "tour-canvas", stage)
    this.cells = new Map()

    for (let y = 0; y < SIZE; y++) {
      for (let x = 0; x < SIZE; x++) {
        const cell = element("div", "tour-cell", canvas)
        const swatch = element("span", "tour-swatch", cell)
        const letter = element("span", "tour-letter", cell)
        this.cells.set(`${x},${y}`, {cell, swatch, letter, color: undefined, painter: undefined})
      }
    }

    const side = element("div", "tour-side", stage)

    this.count = element("div", "tour-count", side)
    this.countNumber = element("span", "tour-count-number", this.count)
    element("span", "tour-count-label", this.count).textContent = "blue pixels at 09:25"

    this.leaders = element("ol", "tour-leaders", side)
    this.leaderRows = Object.entries(PAINTERS).map(([painter, name]) => {
      const row = element("li", "", this.leaders)
      element("span", "tour-leader-name", row).textContent = name
      const track = element("span", "tour-leader-track", row)
      const bar = element("span", "tour-leader-bar", track)
      const count = element("span", "tour-leader-count", row)
      const active = element("span", "tour-leader-active", row)
      return {painter, bar, count, active}
    })

    this.history = element("ol", "tour-history", side)

    this.relations = element("div", "tour-relations", side)
    const header = element("div", "tour-relations-header", this.relations)
    element("span", "", header).textContent = "pixel"
    element("span", "", header).textContent = "painted_by"
    this.relationRows = element("ol", "", this.relations)

    const timeline = element("div", "timeline", root)
    this.track = element("div", "timeline-track", timeline)
    element("span", "timeline-future", this.track).style.left = position(NOW)
    this.activeBand = element("span", "tour-active-band", this.track)
    this.ripple = element("span", "tour-ripple", this.track)
    this.dots = new Map()
    this.marker = element("span", "timeline-marker", this.track)

    const labels = element("div", "timeline-labels", timeline)
    for (const [label, minutes] of [["09:00", 0], ["09:15", 15], ["09:30", 30], ["now", NOW], ["10:00", 60]]) {
      const span = element("span", minutes === NOW ? "is-now" : "", labels)
      span.textContent = label
      span.style.left = position(minutes)
    }

    this.state = null
  }

  show(state, {animate = true} = {}) {
    const previous = this.state
    this.state = state
    this.root.classList.toggle("is-instant", !animate)

    const canvas = canvasAt(state.paints, state.marker)

    this.caption.innerHTML =
      state.marker === NOW
        ? `The canvas <strong>now</strong>, at 09:45`
        : `The canvas <strong>as of ${clock(state.marker)}</strong>`

    // Cells change color in place. A cell that's just been painted pops, while one that
    // changes because we're looking at another moment fades from one color to the other.
    const picked = new Set()
    for (const [key, p] of canvas) if (state.count && p.color === state.count) picked.add(key)
    if (state.history) picked.add(state.history)

    const painted = new Set(state.paints.filter((p) => previous && !previous.paints.includes(p)).map((p) => p.id))

    for (const [key, view] of this.cells) {
      const p = canvas.get(key)
      const color = p ? p.color : null

      if (view.color !== color) {
        view.swatch.style.backgroundColor = fill(color)
        if (animate && p && painted.has(p.id)) replay(view.swatch, "pop")
        view.color = color
      }

      const painter = state.painters && p ? p.painter : null
      if (view.painter !== painter) {
        view.letter.textContent = painter ? PAINTERS[painter][0] : ""
        if (animate && painter) replay(view.letter, "pop")
        view.painter = painter
      }

      view.cell.classList.toggle("is-picked", picked.has(key))
    }

    // Alongside the canvas: a count, the leaderboard, or a pixel's history.
    this.count.hidden = !state.count
    if (state.count) {
      this.countNumber.textContent = [...canvas.values()].filter((p) => p.color === state.count).length
    }

    this.leaders.hidden = !state.leaderboard
    if (state.leaderboard) {
      const rows = leaderboard(canvas, state)
      this.leaderRows.forEach((view, index) => {
        view.bar.style.width = `${rows[index].width}%`
        view.count.textContent = rows[index].count
        view.active.classList.toggle("is-active", rows[index].active)
      })
    }

    this.history.hidden = !state.history
    const historyKey = state.history ? `${state.history}@${state.marker}` : null
    if (state.history && (!previous || historyKey !== this.historyKey)) {
      this.history.replaceChildren(
        ...versions(state).map((version, index) => {
          const row = element("li", animate ? "rise" : "")
          row.style.animationDelay = `${index * 100}ms`
          element("span", "tour-history-swatch", row).style.backgroundColor = fill(version.color)
          element("span", "tour-history-color", row).textContent = version.color || "white"
          element("span", "tour-history-by", row).textContent = version.by
          element("span", "tour-history-at", row).textContent = clock(version.at)
          return row
        })
      )
    }
    this.historyKey = historyKey

    // The relationship each pixel loaded, as of the moment: who had painted it then.
    this.relations.hidden = !state.painters
    const relationsKey = state.painters ? `${state.marker}` : null
    if (state.painters && relationsKey !== this.relationsKey) {
      const pixels = [...canvas.entries()].sort(([a], [b]) => {
        const [ax, ay] = a.split(",").map(Number)
        const [bx, by] = b.split(",").map(Number)
        return ay - by || ax - bx
      })

      this.relationRows.replaceChildren(
        ...pixels.map(([key, p], index) => {
          const row = element("li", animate ? "rise" : "")
          row.style.animationDelay = `${index * 80}ms`
          const pixel = element("span", "tour-relation-pixel", row)
          element("span", "tour-history-swatch", pixel).style.backgroundColor = fill(p.color)
          element("span", "", pixel).textContent = `(${key.replace(",", ", ")})`
          const painter = element("span", "tour-relation-painter", row)
          element("span", "tour-relation-initial", painter).textContent = PAINTERS[p.painter][0]
          element("span", "", painter).textContent = PAINTERS[p.painter]
          return row
        })
      )
    }
    this.relationsKey = relationsKey

    // The timeline: every paint as a dot, and the moment being looked at.
    const ids = new Set(state.paints.map((p) => p.id))
    for (const [id, dot] of this.dots) {
      if (!ids.has(id)) {
        dot.remove()
        this.dots.delete(id)
      }
    }

    for (const p of state.paints) {
      let dot = this.dots.get(p.id)
      if (!dot) {
        dot = element("span", "tour-dot")
        dot.style.left = position(p.at)
        dot.style.backgroundColor = COLORS[p.color]
        this.track.insertBefore(dot, this.marker)
        this.dots.set(p.id, dot)
        if (animate && previous) replay(dot, "pop")
      }
      dot.classList.toggle("is-dim", Boolean(state.history) && p.cell !== state.history)
      dot.classList.toggle("is-focus", state.history === p.cell)
    }

    this.marker.style.left = position(state.marker)

    this.activeBand.hidden = state.active === undefined
    if (state.active !== undefined) {
      this.activeBand.style.left = position(state.marker - state.active)
      this.activeBand.style.width = position(state.active)
    }

    this.ripple.hidden = !state.ripple
    if (state.ripple) {
      this.ripple.style.left = position(state.ripple[0])
      this.ripple.style.width = position(state.ripple[1] - state.ripple[0])
      if (animate && !(previous && previous.ripple)) replay(this.ripple, "sweep")
    }
  }
}
