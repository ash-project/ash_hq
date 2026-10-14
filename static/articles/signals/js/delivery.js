// Placing an order, and its listeners, over time. Each listener runs inline, in the order's
// transaction, or in an Oban job after it commits, and any of them can fail.

import {highlight} from "./highlight.js"

// In the order Ash finds them: by resource
const LISTENERS = [
  {key: "fulfillment", name: "Fulfillment", resource: "Fulfillment.Shipment", action: "open_shipment", queue: "fulfillment", does: "Opens a shipment", takes: 0.7},
  {key: "inventory", name: "Inventory", resource: "Inventory.Reservation", action: "reserve_stock", queue: "inventory", does: "Reserves stock", takes: 0.5},
  {key: "loyalty", name: "Loyalty", resource: "Loyalty.PointsEntry", action: "earn_points", queue: "loyalty", does: "Adds points", takes: 0.45},
  {key: "notifications", name: "Notifications", resource: "Notifications.Receipt", action: "send_receipt", queue: "mailers", does: "Emails a receipt", takes: 0.8, email: true},
  {key: "reporting", name: "Reporting", resource: "Reporting.Sale", action: "record_sale", queue: "reporting", does: "Records the sale", takes: 0.5},
]

// Times are in made-up units, and each takes UNIT milliseconds to play. The timeline is at
// least MIN_SPAN of them wide.
const UNIT = 430
const MIN_SPAN = 6
const INSERT = 0.5
// Inserting a job, in the order's transaction
const ENQUEUE = 0.18
// How long after the commit the first job is picked up, and the next, and so on
const PICKUP = 0.3
const STAGGER = 0.12
// How long Oban waits before retrying a failed job
const BACKOFF = 0.8
// How far through a listener it fails
const FAILS_AT = 0.6

const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)")

// "A", "A and B", "A, B and C"
const list = (names) => (names.length < 2 ? names.join("") : `${names.slice(0, -1).join(", ")} and ${names.at(-1)}`)

// The listeners as they're declared, each in its own resource, and which lines say they run in
// jobs.
function code(deliveries) {
  const lines = []
  const marked = []

  LISTENERS.forEach((listener, index) => {
    if (index > 0) lines.push("")
    lines.push(`# ${listener.resource}`)

    if (deliveries[listener.key] === "job") {
      lines.push(`on :order_placed, :${listener.action},`)
      marked.push(lines.length)
      lines.push(`  delivery: {AshOban.Signals, queue: :${listener.queue}}`)
    } else {
      lines.push(`on :order_placed, :${listener.action}`)
    }
  })

  return {source: lines.join("\n"), marked}
}

// What happens, worked out up front: the blocks in each lane, the transaction, and when
// `place_order!` returns.
function simulate(deliveries, failing) {
  const order = [{from: 0, to: INSERT, kind: "order", label: "INSERT", undoable: true}]
  const lanes = Object.fromEntries(LISTENERS.map((listener) => [listener.key, []]))
  const inJobs = (listener) => deliveries[listener.key] === "job"

  // Ash calls each delivery once, with the listeners that use it with the same options, in the
  // order it first finds one of them. Every inline listener shares one call, and each job
  // listener here has its own queue, so a call of its own.
  const calls = []
  for (const listener of LISTENERS) {
    const key = inJobs(listener) ? listener.queue : "inline"
    let call = calls.find((call) => call.key === key)
    if (!call) calls.push((call = {key, listeners: []}))
    call.listeners.push(listener)
  }

  let at = INSERT
  let failed = null
  let emailed = false
  const enqueued = []

  for (const listener of calls.flatMap((call) => call.listeners)) {
    if (failed) {
      lanes[listener.key].push({skipped: true, at})
    } else if (inJobs(listener)) {
      lanes[listener.key].push({from: at, to: at + ENQUEUE, kind: "enqueue", undoable: true})
      enqueued.push(listener)
      at += ENQUEUE
    } else if (failing.has(listener.key)) {
      // The inline delivery stops at the first listener that fails, and so does the emit.
      const to = at + listener.takes * FAILS_AT
      lanes[listener.key].push({from: at, to, kind: "fail", status: "✕"})
      failed = listener
      at = to
    } else {
      lanes[listener.key].push({from: at, to: at + listener.takes, kind: "ok", status: listener.email ? "✉" : "✓", email: listener.email, undoable: !listener.email})
      emailed ||= Boolean(listener.email)
      at += listener.takes
    }
  }

  let end = at
  const retried = []

  if (!failed) {
    enqueued.forEach((listener, index) => {
      const from = at + PICKUP + index * STAGGER
      const status = listener.email ? "✉" : "✓"

      if (failing.has(listener.key)) {
        const failsAt = from + listener.takes * FAILS_AT
        const retry = failsAt + BACKOFF
        lanes[listener.key].push(
          {from, to: failsAt, kind: "fail", label: "job", status: "✕"},
          {from: retry, to: retry + listener.takes, kind: "ok", label: "retry", status}
        )
        retried.push(listener.name)
        end = Math.max(end, retry + listener.takes)
      } else {
        lanes[listener.key].push({from, to: from + listener.takes, kind: "ok", label: "job", status})
        end = Math.max(end, from + listener.takes)
      }
    })
  }

  const inline = LISTENERS.filter((listener) => !inJobs(listener))
  const jobs = LISTENERS.filter(inJobs)
  const names = (listeners) => list(listeners.map((listener) => listener.name))
  let summary

  if (failed) {
    // The receipt, if it was going to be sent from a job
    const receiptJob = jobs.find((listener) => listener.email)
    const skipped = LISTENERS.filter((listener) => lanes[listener.key][0]?.skipped && listener !== receiptJob)
    summary =
      `<strong>No order.</strong> ${failed.name} failed, so the whole transaction got rolled back, along with ` +
      `everything written in it` +
      (enqueued.length ? `, including the ${enqueued.length === 1 ? "job" : "jobs"} for ${names(enqueued)}. ` : ". ") +
      (skipped.length ? `${names(skipped)} never ran. ` : "") +
      `Nobody can check out while ${failed.name} is broken.` +
      (emailed ? " And the receipt had already gone out, and an email can't be rolled back." : "") +
      (receiptJob ? ` At least no receipt went out, since its job ${enqueued.includes(receiptJob) ? "got rolled back with the order" : "was never inserted"}.` : "")
  } else if (!jobs.length) {
    summary =
      `<strong>Order placed!</strong> The order and all five listeners committed together, in one transaction. ` +
      `<code>place_order!</code> returned once all of them had finished.`
  } else {
    summary =
      `<strong>Order placed!</strong> ` +
      (inline.length
        ? `${names(inline)} ran in the order's transaction, and ${names(jobs)} ran in ${jobs.length === 1 ? "a job" : "jobs"} after it committed. `
        : `The order committed with a job for each listener. `) +
      `<code>place_order!</code> didn't wait for ${jobs.length === 1 ? "the job" : "the jobs"}.` +
      (retried.length ? ` ${list(retried)} failed, and Oban retried ${retried.length === 1 ? "it" : "them"}, without affecting the order or the other listeners.` : "")
  }

  return {
    order,
    lanes,
    band: {to: at, end: failed ? "ROLLBACK" : "COMMIT"},
    returns: {at, label: failed ? "returns an error" : "returns"},
    rollback: failed ? at : null,
    end,
    summary,
  }
}

const element = (tag, className, parent) => {
  const el = document.createElement(tag)
  if (className) el.className = className
  if (parent) parent.appendChild(el)
  return el
}

// A listener's controls: how signals reach it, and whether it fails.
function controls(listener, parent) {
  const row = element("div", "listener-row", parent)
  const name = element("span", "listener-name", row)
  name.id = `delivery-${listener.key}`
  name.textContent = listener.name

  const segmented = element("div", "segmented", row)
  segmented.setAttribute("role", "radiogroup")
  segmented.setAttribute("aria-labelledby", name.id)

  for (const [value, label] of [["inline", "Inline"], ["job", "In a job"]]) {
    const option = element("label", "", segmented)
    const input = element("input", "", option)
    input.type = "radio"
    input.name = listener.key
    input.value = value
    input.checked = value === "inline"
    element("span", "", option).textContent = label
  }

  const chip = element("label", "chip is-failing", row)
  const input = element("input", "", chip)
  input.type = "checkbox"
  input.name = "fail"
  input.value = listener.key
  input.setAttribute("aria-label", `${listener.name} fails`)
  chip.append("Fails")
}

export function delivery(figure) {
  figure.hidden = false

  const form = figure.querySelector("form")
  const codeBlock = figure.querySelector("[data-code] code")
  const lanesEl = figure.querySelector("[data-timeline]")
  const result = figure.querySelector("[data-result]")
  let timers = []

  for (const listener of LISTENERS) controls(listener, figure.querySelector("[data-listeners]"))

  const read = () => {
    const data = new FormData(form)
    return {
      deliveries: Object.fromEntries(LISTENERS.map((listener) => [listener.key, data.get(listener.key)])),
      failing: new Set(data.getAll("fail")),
    }
  }

  const showCode = (deliveries) => {
    const {source, marked} = code(deliveries)
    codeBlock.innerHTML = highlight(source, "elixir")
      .split("\n")
      .map((line, index) => `<span class="line${marked.includes(index) ? " is-highlighted" : ""}">${line || " "}</span>`)
      .join("")
  }

  const play = () => {
    timers.forEach(clearTimeout)
    timers = []

    const {deliveries, failing} = read()
    const run = simulate(deliveries, failing)
    const span = Math.max(MIN_SPAN, run.end * 1.04)
    const percent = (time) => `${(time * 100) / span}%`
    const unit = reducedMotion.matches ? 0 : UNIT
    const later = (time, fn) => timers.push(setTimeout(fn, time * unit))

    showCode(deliveries)
    result.innerHTML = unit ? "Placing an order…" : run.summary
    lanesEl.replaceChildren()

    // Behind the lanes: the transaction, growing as it runs
    const back = element("div", "lane-overlay", lanesEl)
    const band = element("div", "lane-band", back)
    band.style.width = percent(run.band.to)
    band.style.animation = `grow ${run.band.to * unit}ms linear both`

    const tag = (text, at, {end = false, bad = false} = {}) => {
      const el = element("span", `lane-tag pop${end ? " is-end" : ""}${bad ? " is-bad" : ""}`, back)
      el.textContent = text
      el.style.left = percent(at)
      el.style.animationDelay = `${at * unit}ms`
    }

    if (run.band.to / span > 0.3) tag("BEGIN", 0)
    tag(run.band.end, run.band.to, {end: run.band.to / span > 0.5, bad: run.band.end === "ROLLBACK"})

    const blocks = []

    const lane = (row, name, does, items) => {
      const label = element("div", "lane-name", lanesEl)
      label.style.gridRow = row
      element("strong", "", label).textContent = name
      element("span", "lane-does", label).textContent = does

      const track = element("div", "lane-track", lanesEl)
      track.style.gridRow = row

      for (const item of items) {
        if (item.skipped) {
          const status = element("span", "lane-status is-skipped pop", track)
          status.textContent = "never ran"
          status.style.left = percent(item.at)
          status.style.animationDelay = `${item.at * unit}ms`
          continue
        }

        const block = element("span", `lane-block is-${item.kind} grow`, track)
        block.textContent = item.label || ""
        block.style.left = percent(item.from)
        block.style.width = percent(item.to - item.from)
        block.style.animationDuration = `${(item.to - item.from) * unit}ms`
        block.style.animationTimingFunction = "linear"
        block.style.animationDelay = `${item.from * unit}ms`

        let status = null
        if (item.status) {
          status = element("span", `lane-status pop${item.kind === "fail" ? " is-fail" : ""}`, track)
          status.textContent = item.status
          status.style.left = percent(item.to)
          status.style.animationDelay = `${item.to * unit}ms`
        }

        blocks.push({item, block, status})
      }
    }

    lane(2, "Shop.Order", "Places the order", run.order)
    LISTENERS.forEach((listener, index) => {
      lane(index + 3, listener.name, deliveries[listener.key] === "job" ? `${listener.does}, in a job` : listener.does, run.lanes[listener.key])
    })

    // In front of the lanes: when the action returns, and the playhead
    const front = element("div", "lane-overlay", lanesEl)
    const returns = element("div", `lane-returns pop${run.returns.at / span > 0.5 ? " is-end" : ""}`, front)
    returns.style.left = percent(run.returns.at)
    returns.style.animationDelay = `${run.returns.at * unit}ms`
    const label = element("span", "", returns)
    element("span", "lane-returns-call", label).textContent = "place_order! "
    label.append(run.returns.label)

    if (unit) {
      const playhead = element("div", "lane-playhead", front)
      playhead.style.setProperty("--to", percent(run.end))
      playhead.style.animationDuration = `${run.end * unit}ms`
    }

    // A rollback undoes everything written in the transaction, jobs included, but not an email
    // that's already gone.
    if (run.rollback !== null) {
      later(run.rollback, () => {
        band.classList.add("is-rolled-back")
        for (const {item, block, status} of blocks) {
          if (item.undoable) block.classList.add("is-undone")
          if (item.email && status) {
            status.textContent = "✉ already sent"
            status.classList.add("is-warning")
          }
        }
      })
    }

    if (unit) later(run.end, () => (result.innerHTML = run.summary))
  }

  form.addEventListener("change", play)
  form.addEventListener("submit", (event) => {
    event.preventDefault()
    play()
  })

  showCode(read().deliveries)

  // It plays by itself the first time it comes into view.
  const firstView = new IntersectionObserver(
    ([entry]) => {
      if (!entry.isIntersecting) return
      firstView.disconnect()
      play()
    },
    {threshold: 0.4}
  )
  firstView.observe(figure)
}
