import {dial} from "./hero.js"
import {highlight, highlightAll} from "./highlight.js"
import {reveal} from "./reveal.js"
import {scrolly} from "./scrolly.js"
import {STATES as TOUR_STATES, TourView} from "./tour.js"
import {COLORS, PeriodsView, clock, run, sql} from "./periods.js"

dial(document.getElementById("hero-dial"))
highlightAll()

reveal(document.getElementById("reveal"))

// The tour of what `as_of` does
scrolly(
  document.getElementById("tour"),
  new TourView(document.getElementById("tour-visual")),
  TOUR_STATES
)

// One pixel's rows in Postgres, statement by statement
const STATEMENTS = [
  {type: "insert", color: "pink", from: 5},
  {type: "update", color: "blue", from: 72, to: null},
  {type: "update", color: "yellow", from: 30, to: 45},
  {type: "delete", from: 120, to: 150},
]

const pgStates = {empty: []}
STATEMENTS.reduce((rows, statement, index) => (pgStates[`s${index}`] = run(rows, statement)), [])

scrolly(document.getElementById("postgres"), new PeriodsView(document.getElementById("postgres-visual")), pgStates)

// The playground: write to the pixel's history, and read it as of any moment.
const playground = document.getElementById("playground")
const view = new PeriodsView(playground.querySelector("[data-view]"))
const form = playground.querySelector("form")
const preview = playground.querySelector("[data-preview] code")
const select = playground.querySelector("[data-select] code")
const result = playground.querySelector("[data-result]")
const slider = playground.querySelector("[data-reader]")

let rows = pgStates.s3
let reading = 60

const options = (el, values, selected) => {
  el.replaceChildren(
    ...values.map(([label, value]) => {
      const option = document.createElement("option")
      option.textContent = label
      option.value = value
      option.selected = value === selected
      return option
    })
  )
}

const quarters = (from, to) => {
  const times = []
  for (let minutes = from; minutes <= to; minutes += 15) times.push([clock(minutes), String(minutes)])
  return times
}

options(form.elements.from, quarters(0, 165), "90")
options(form.elements.to, [...quarters(15, 180), ["NULL (forever)", "null"]], "135")

for (const color of Object.keys(COLORS)) {
  const label = document.createElement("label")
  label.className = "chip"
  label.innerHTML = `<input type="radio" name="color" value="${color}" ${color === "green" ? "checked" : ""}><span style="--swatch: ${COLORS[color]}"></span>${color}`
  form.querySelector("[data-colors]").append(label)
}

const statement = () => {
  const data = new FormData(form)
  const to = data.get("to") === "null" ? null : Number(data.get("to"))
  return {type: data.get("type"), color: data.get("color"), from: Number(data.get("from")), to}
}

const valid = ({from, to}) => to === null || to > from

const refresh = () => {
  const current = statement()
  preview.innerHTML = highlight(sql(current), "sql")
  form.querySelector("[data-colors]").toggleAttribute("disabled", current.type === "delete")
  form.querySelectorAll("[data-colors] input").forEach((input) => (input.disabled = current.type === "delete"))
  form.querySelector("[type=submit]").disabled = !valid(current)
  playground.querySelector("[data-invalid]").hidden = valid(current)
}

const read = (minutes) => {
  reading = minutes
  const found = view.read(minutes)
  select.innerHTML = highlight(
    `-- Canvas.get_pixel!(3, 7, as_of: ...)\nSELECT * FROM pixels\n  WHERE valid_at @> '${clock(minutes)}'\n  AND x = 3 AND y = 7;`,
    "sql"
  )
  result.innerHTML = found
    ? `<span class="swatch" style="background-color: ${COLORS[found.color]}"></span> 1 row: <strong>${found.color}</strong> at ${clock(minutes)}`
    : `No rows: the pixel didn't exist at ${clock(minutes)}`
  slider.setAttribute("aria-valuenow", minutes)
  slider.setAttribute("aria-valuetext", clock(minutes))
}

form.addEventListener("change", refresh)

form.addEventListener("submit", (event) => {
  event.preventDefault()
  const current = statement()
  if (!valid(current)) return
  rows = run(rows, current)
  view.show(rows)
  read(reading)
})

playground.querySelector("[data-reset]").addEventListener("click", () => {
  rows = pgStates.s3
  view.show(rows, {animate: false})
  read(reading)
})

// Drag along the timeline, or use the arrow keys, to read as of any moment.
const track = view.track
track.addEventListener("pointerdown", (event) => {
  track.setPointerCapture(event.pointerId)
  read(view.minutesAt(event.clientX))
})
track.addEventListener("pointermove", (event) => {
  if (track.hasPointerCapture(event.pointerId)) read(view.minutesAt(event.clientX))
})
slider.addEventListener("keydown", (event) => {
  const by = {ArrowRight: 5, ArrowUp: 5, ArrowLeft: -5, ArrowDown: -5, PageUp: 30, PageDown: -30}[event.key]
  if (by === undefined) return
  event.preventDefault()
  read(Math.min(Math.max(reading + by, 0), 179))
})

view.show(rows, {animate: false})
read(reading)
refresh()

// The comparison fills in its last column as each row comes into view.
const comparison = new IntersectionObserver(
  (entries) => {
    for (const entry of entries) {
      if (entry.isIntersecting) {
        entry.target.classList.add("is-revealed")
        comparison.unobserve(entry.target)
      }
    }
  },
  {threshold: 0.8}
)

document.querySelectorAll("#comparison tbody tr").forEach((row) => comparison.observe(row))
