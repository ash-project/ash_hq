// One pixel's rows in a PostgreSQL 19 table with an application-time period, and what
// each statement does to them. Times are minutes past 09:00, from 09:00 to 12:00, and a
// period that never ends has `to: null`.

export const COLORS = {pink: "#FF99AA", yellow: "#FFD635", green: "#00A368", blue: "#2450A4"}
const SPAN = 180

let nextId = 1
const newId = () => `row-${nextId++}`

export const clock = (minutes) =>
  `${String(9 + Math.floor(minutes / 60)).padStart(2, "0")}:${String(minutes % 60).padStart(2, "0")}`

const overlaps = (row, from, to) => (row.to === null || row.to > from) && (to === null || row.from < to)
const sorted = (rows) => [...rows].sort((a, b) => a.from - b.from)

export function insert(rows, {color, from}) {
  return sorted([...rows, {id: newId(), color, from, to: null}])
}

// `UPDATE ... FOR PORTION OF` and `DELETE ... FOR PORTION OF`: only the part of each row
// within the portion is changed, or removed, and Postgres inserts what's left of the row
// on either side of it as rows of their own.
function forPortion(rows, from, to, change) {
  const result = []

  for (const row of rows) {
    if (!overlaps(row, from, to)) {
      result.push(row)
      continue
    }

    const before = row.from < from ? {...row, to: from} : null
    const after = to !== null && (row.to === null || row.to > to) ? {...row, id: newId(), from: to, appears: true} : null
    const portion = {
      ...row,
      id: before ? newId() : row.id,
      from: Math.max(row.from, from),
      to: row.to === null ? to : to === null ? row.to : Math.min(row.to, to),
      appears: false,
    }

    if (before) result.push(before)
    const changed = change(portion)
    if (changed) result.push(changed)
    if (after) result.push(after)
  }

  return sorted(result)
}

export const update = (rows, {color, from, to}) => forPortion(rows, from, to, (row) => ({...row, color}))
export const remove = (rows, {from, to}) => forPortion(rows, from, to, () => null)

export function sql(statement) {
  const to = statement.to === null ? "NULL" : `'${clock(statement.to)}'`

  switch (statement.type) {
    case "insert":
      return `INSERT INTO pixels (x, y, color, valid_at)\n  VALUES (3, 7, '${statement.color}', '[${clock(statement.from)},)');`
    case "update":
      return `UPDATE pixels\n  FOR PORTION OF valid_at FROM '${clock(statement.from)}' TO ${to}\n  SET color = '${statement.color}'\n  WHERE x = 3 AND y = 7;`
    case "delete":
      return `DELETE FROM pixels\n  FOR PORTION OF valid_at FROM '${clock(statement.from)}' TO ${to}\n  WHERE x = 3 AND y = 7;`
  }
}

export function run(rows, statement) {
  switch (statement.type) {
    case "insert":
      return insert(rows, statement)
    case "update":
      return update(rows, statement)
    case "delete":
      return remove(rows, statement)
  }
}

export const rowAt = (rows, minutes) =>
  rows.find((row) => row.from <= minutes && (row.to === null || minutes < row.to))

const element = (tag, className, parent) => {
  const el = document.createElement(tag)
  if (className) el.className = className
  if (parent) parent.appendChild(el)
  return el
}

function replay(el, className) {
  el.classList.remove(className)
  void el.offsetWidth
  el.classList.add(className)
}

const range = (row) => `[${clock(row.from)}, ${row.to === null ? "∞" : clock(row.to)})`

// The rows as a table, and as stretches along a timeline.
export class PeriodsView {
  constructor(root) {
    this.root = root
    root.classList.add("periods")

    const table = element("table", "periods-table", root)
    const head = element("tr", "", element("thead", "", table))
    for (const column of ["x", "y", "color", "valid_at"]) element("th", "", head).textContent = column
    this.body = element("tbody", "", table)
    this.empty = element("p", "periods-empty", root)
    this.empty.textContent = "No rows yet"

    const timeline = element("div", "timeline periods-timeline", root)
    this.track = element("div", "timeline-track", timeline)
    this.marker = element("span", "timeline-marker is-reading", this.track)
    this.marker.hidden = true

    const labels = element("div", "timeline-labels", timeline)
    for (const [label, minutes] of [["09:00", 0], ["10:00", 60], ["11:00", 120], ["12:00", 180]]) {
      const span = element("span", "", labels)
      span.textContent = label
      span.style.left = `${(minutes * 100) / SPAN}%`
    }

    this.rows = new Map()
    this.segments = new Map()
  }

  show(rows, {animate = true} = {}) {
    this.root.classList.toggle("is-instant", !animate)
    this.empty.hidden = rows.length > 0
    const ids = new Set(rows.map((row) => row.id))

    for (const [id, view] of this.rows) {
      if (!ids.has(id)) {
        view.tr.remove()
        this.segments.get(id).remove()
        this.rows.delete(id)
        this.segments.delete(id)
      }
    }

    rows.forEach((row, index) => {
      let view = this.rows.get(row.id)

      if (!view) {
        const tr = element("tr", animate ? "rise" : "")
        element("td", "", tr).textContent = "3"
        element("td", "", tr).textContent = "7"
        const color = element("td", "", tr)
        const swatch = element("span", "swatch", color)
        const name = element("span", "", color)
        const period = element("span", "period", element("td", "", tr))
        view = {tr, swatch, name, period, range: null, color: null}
        this.rows.set(row.id, view)

        const segment = element("span", "periods-segment")
        this.track.insertBefore(segment, this.marker)
        this.segments.set(row.id, segment)
        this.place(segment, row)
        if (animate) replay(segment, row.appears ? "fade" : "grow")
      }

      this.body.insertBefore(view.tr, this.body.children[index] || null)

      if (view.color !== row.color) {
        view.swatch.style.backgroundColor = COLORS[row.color]
        view.name.textContent = row.color
        this.segments.get(row.id).style.backgroundColor = COLORS[row.color]
        view.color = row.color
      }

      if (view.range !== range(row)) {
        view.period.textContent = range(row)
        if (animate && view.range !== null) replay(view.period, "flash")
        view.range = range(row)
        this.place(this.segments.get(row.id), row)
      }
    })

    this.current = rows
    if (this.reading !== undefined) this.read(this.reading)
  }

  place(segment, row) {
    segment.style.left = `${(row.from * 100) / SPAN}%`
    segment.style.width = `${(((row.to === null ? SPAN : row.to) - row.from) * 100) / SPAN}%`
    segment.classList.toggle("is-open", row.to === null)
  }

  // Marks the row valid at a moment, as reading as of that moment would find it.
  read(minutes) {
    this.reading = minutes
    this.marker.hidden = false
    this.marker.style.left = `${(minutes * 100) / SPAN}%`
    const found = rowAt(this.current || [], minutes)

    for (const [id, view] of this.rows) view.tr.classList.toggle("is-current", found !== undefined && found.id === id)
    return found
  }

  // The moment at a point along the timeline.
  minutesAt(clientX) {
    const rect = this.track.getBoundingClientRect()
    const fraction = Math.min(Math.max((clientX - rect.left) / rect.width, 0), 1)
    return Math.min(Math.round(fraction * SPAN), SPAN - 1)
  }
}
