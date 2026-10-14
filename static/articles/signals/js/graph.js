// The shop from the article, with an arrow from each part of it to the parts it depends on,
// and what signals do to those arrows. A step of the article moves through a few of these
// states in turn.

const SVG = "http://www.w3.org/2000/svg"
const LISTENERS = ["fulfillment", "inventory", "loyalty", "notifications", "reporting"]

// Centers, in a 720 × 410 drawing. Boxes are 160 × 52 unless they say otherwise.
const NODES = {
  shop: {x: 110, y: 210, w: 140, h: 60, label: "Shop", sub: "Order"},
  signals: {x: 350, y: 210, w: 156, label: "Shop.Signals", sub: ":order_placed", contract: true},
  fulfillment: {x: 600, y: 50, label: "Fulfillment", sub: "Shipment"},
  inventory: {x: 600, y: 130, label: "Inventory", sub: "Reservation"},
  loyalty: {x: 600, y: 210, label: "Loyalty", sub: "PointsEntry"},
  notifications: {x: 600, y: 290, label: "Notifications", sub: "Receipt"},
  reporting: {x: 600, y: 370, label: "Reporting", sub: "Sale"},
}

// Where the listeners' boxes start, on the left
const LEFT = 520

// A listener's arrow to the signal module, arriving at its rounded right end a little above or
// below the middle, depending on where the listener is.
const toSignals = (y) => {
  const offset = (y - 210) * 0.13
  const end = 402 + Math.sqrt(26 ** 2 - offset ** 2) + 4
  return `M ${LEFT} ${y} C 478 ${y}, ${end + 42} ${210 + offset}, ${end} ${210 + offset}`
}

// Every arrow points from a module to one it depends on, and is drawn from its start.
const EDGES = {
  ...Object.fromEntries(LISTENERS.map((key) => [`call-${key}`, `M 180 210 L ${LEFT - 4} ${NODES[key].y}`])),
  "back-fulfillment": "M 520 40 C 400 8, 180 18, 122 176",
  "back-loyalty": "M 520 224 C 420 282, 262 282, 164 244",
  emit: "M 180 210 L 268 210",
  ...Object.fromEntries(LISTENERS.map((key) => [`listen-${key}`, toSignals(NODES[key].y)])),
}

const calls = LISTENERS.map((key) => `call-${key}`)
const listens = LISTENERS.map((key) => `listen-${key}`)
const backs = ["back-fulfillment", "back-loyalty"]
const everyone = ["shop", ...LISTENERS]

const after = (state) => ({quiet: backs, ...state})

export const STATES = {
  one: {nodes: ["shop"], edges: [], caption: "<strong>Shop</strong> depends on nothing else"},
  calls: {nodes: everyone, edges: calls, caption: "<strong>Shop</strong> depends on five other domains"},
  cycles: {
    nodes: everyone,
    edges: [...calls, ...backs],
    cycles: ["call-fulfillment", "call-loyalty", ...backs],
    caption: `<span class="is-bad">Two of them depend on Shop, too</span>`,
  },
  contract: after({
    nodes: [...everyone, "signals"],
    edges: ["emit", ...backs],
    caption: "<strong>Shop</strong> depends only on its signals",
  }),
  inverted: after({
    nodes: [...everyone, "signals"],
    edges: ["emit", ...listens, ...backs],
    caption: "Every listener depends on <strong>Shop.Signals</strong>",
  }),
  flow: after({
    nodes: [...everyone, "signals"],
    edges: ["emit", ...listens, ...backs],
    flow: true,
    caption: "Placing an order: <strong>:order_placed</strong> goes out to every listener",
  }),
}

const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)")

const svg = (tag, attributes = {}, parent) => {
  const el = document.createElementNS(SVG, tag)
  for (const [name, value] of Object.entries(attributes)) el.setAttribute(name, value)
  if (parent) parent.appendChild(el)
  return el
}

const html = (tag, className, parent) => {
  const el = document.createElement(tag)
  if (className) el.className = className
  if (parent) parent.appendChild(el)
  return el
}

// Restarts a CSS animation on an element.
function replay(el, className) {
  el.classList.remove(className)
  void el.getBoundingClientRect()
  el.classList.add(className)
}

const ease = (t) => (t < 0.5 ? 2 * t * t : 1 - (-2 * t + 2) ** 2 / 2)

export class GraphView {
  constructor(root) {
    this.root = root
    root.classList.add("graph")

    this.caption = html("p", "visual-caption", root)

    this.svg = svg("svg", {viewBox: "0 0 720 410", "aria-hidden": "true"}, root)
    const edges = svg("g", {}, this.svg)
    const nodes = svg("g", {}, this.svg)
    this.pulseLayer = svg("g", {}, this.svg)

    this.edges = new Map()
    for (const [key, d] of Object.entries(EDGES)) {
      const group = svg("g", {class: "graph-edge"}, edges)
      const path = svg("path", {class: "graph-line", d}, group)
      const length = path.getTotalLength()

      // The line stops short of its end, where the arrowhead's tip is.
      group.style.setProperty("--visible", `${length - 7}px`)
      group.style.setProperty("--gap", `${length * 2}px`)

      const tip = path.getPointAtLength(length)
      const before = path.getPointAtLength(length - 6)
      const angle = (Math.atan2(tip.y - before.y, tip.x - before.x) * 180) / Math.PI
      svg("path", {class: "graph-arrow", d: "M 0 0 L -9 -4 L -9 4 Z", transform: `translate(${tip.x} ${tip.y}) rotate(${angle})`}, group)

      this.edges.set(key, {group, path, length})
    }

    this.nodes = new Map()
    for (const [key, node] of Object.entries(NODES)) {
      const {x, y, w = 160, h = 52} = node
      const group = svg("g", {class: `graph-node${node.contract ? " is-contract" : ""}`}, nodes)
      svg("rect", {x: x - w / 2, y: y - h / 2, width: w, height: h, rx: node.contract ? h / 2 : 10}, group)
      svg("text", {class: "graph-label", x, y: y - 1}, group).textContent = node.label
      svg("text", {class: "graph-sub", x, y: y + 16}, group).textContent = node.sub
      this.nodes.set(key, group)
    }

    const legend = html("p", "graph-legend", root)
    legend.setAttribute("aria-hidden", "true")
    const arrow = html("span", "", legend)
    const icon = svg("svg", {viewBox: "0 0 26 10", width: 26, height: 10, class: "graph-legend-arrow"}, arrow)
    svg("path", {d: "M 1 5 L 17 5", class: "graph-legend-line"}, icon)
    svg("path", {d: "M 25 5 L 16 1 L 16 9 Z", class: "graph-legend-head"}, icon)
    arrow.append("depends on")
    html("span", "graph-legend-pulse", legend).append("a signal")

    this.pulses = []
    this.frame = null
    this.visible = true
    new IntersectionObserver(([entry]) => (this.visible = entry.isIntersecting)).observe(root)

    this.state = null
  }

  show(state, {animate = true} = {}) {
    this.state = state
    this.root.classList.toggle("is-instant", !animate)
    this.caption.innerHTML = state.caption

    for (const [key, group] of this.nodes) group.classList.toggle("is-shown", state.nodes.includes(key))

    // Arrows that appear draw in one after another.
    let appearing = 0
    for (const [key, {group}] of this.edges) {
      const shown = state.edges.includes(key)
      if (shown && !group.classList.contains("is-shown")) group.style.setProperty("--delay", `${appearing++ * 160}ms`)
      group.classList.toggle("is-shown", shown)
      group.classList.toggle("is-cycle", Boolean(state.cycles?.includes(key)))
      group.classList.toggle("is-quiet", Boolean(state.quiet?.includes(key)))
      group.classList.toggle("is-signal", key === "emit" || key.startsWith("listen-"))
    }

    if (state.flow && animate && !reducedMotion.matches) {
      this.startFlow()
    } else {
      this.stopFlow()
    }
  }

  // A signal leaves the shop, reaches the signal module, and goes out to every listener, over
  // and over while the state lasts.
  startFlow() {
    if (this.flowTimer) return

    const fire = () => {
      if (!this.visible) return
      this.flash("shop")
      this.send("emit", {duration: 650}, () => {
        this.flash("signals")
        for (const key of LISTENERS) {
          this.send(`listen-${key}`, {duration: 800, reverse: true}, () => this.flash(key))
        }
      })
    }

    const loop = () => {
      fire()
      this.flowTimer = setTimeout(loop, 3200)
    }

    this.flowTimer = setTimeout(loop, 700)
  }

  stopFlow() {
    clearTimeout(this.flowTimer)
    this.flowTimer = null
    for (const pulse of this.pulses) pulse.dot.remove()
    this.pulses = []
  }

  flash(key) {
    replay(this.nodes.get(key), "is-hit")
  }

  send(key, {duration, reverse = false}, arrived) {
    const {path, length} = this.edges.get(key)
    const dot = svg("circle", {class: "graph-pulse", r: 5}, this.pulseLayer)
    this.pulses.push({path, length, reverse, duration, arrived, dot, start: performance.now()})
    this.tick()
  }

  tick() {
    if (this.frame) return
    this.frame = requestAnimationFrame((now) => {
      this.frame = null

      // Pulses that arrive can send more, so they're told once this frame's are dealt with.
      const arrivals = []
      this.pulses = this.pulses.filter((pulse) => {
        const t = Math.min((now - pulse.start) / pulse.duration, 1)
        const along = ease(t) * pulse.length
        const point = pulse.path.getPointAtLength(pulse.reverse ? pulse.length - along : along)
        pulse.dot.setAttribute("cx", point.x)
        pulse.dot.setAttribute("cy", point.y)

        if (t < 1) return true
        pulse.dot.remove()
        arrivals.push(pulse.arrived)
        return false
      })

      arrivals.forEach((arrived) => arrived())
      if (this.pulses.length) this.tick()
    })
  }
}
