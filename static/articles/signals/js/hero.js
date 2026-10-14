// Behind the title: a tangle of modules, each depending on a few of the others and some on each
// other, that sorts itself out into modules depending on one contract between them. Then
// signals go out through it: from a module that emits them, into the contract, and out to the
// ones that listen.

const SVG = "http://www.w3.org/2000/svg"

// Where each module starts, in a 100 × 100 drawing centred on 0, 0
const TANGLED = [
  [-30, -8], [22, 28], [-6, -34], [34, -14], [-20, 30],
  [8, 6], [-38, 18], [26, -36], [-10, 12], [12, -18],
]

// Each one depends on these, as [from, to]. The ones in a cycle are drawn in red.
const TANGLE = [
  [0, 5], [5, 0], [1, 3], [3, 7], [7, 1], [2, 8], [8, 4], [4, 6], [6, 0],
  [9, 2], [2, 9], [5, 1], [8, 3], [6, 9], [4, 5], [7, 8], [3, 0],
]
const CYCLES = new Set(["0-5", "5-0", "2-9", "9-2", "1-3", "3-7", "7-1"])

// Where they end up: the contract a little left of the middle, the modules that emit signals
// to its left, and the ones that listen fanned out to its right. Every arrow points at it.
const HUB_AT = [-6, 0]
const at = (radius, degrees) => [HUB_AT[0] + radius * Math.cos((degrees * Math.PI) / 180), HUB_AT[1] + radius * Math.sin((degrees * Math.PI) / 180)]
const SLOTS = [
  ...[152, 180, 208].map((degrees) => ({point: at(31, degrees), emits: true})),
  ...[-66, -44, -22, 0, 22, 44, 66].map((degrees) => ({point: at(41, degrees), emits: false})),
]

// Each module keeps its place going around, so that they move outward rather than across each
// other.
const around = ([x, y]) => Math.atan2(y - HUB_AT[1], x - HUB_AT[0])
const CLEAN = []
const EMITTERS = []
{
  const modules = TANGLED.map((point, index) => index).sort((a, b) => around(TANGLED[a]) - around(TANGLED[b]))
  const slots = [...SLOTS].sort((a, b) => around(a.point) - around(b.point))
  modules.forEach((index, rank) => {
    CLEAN[index] = slots[rank].point
    if (slots[rank].emits) EMITTERS.push(index)
  })
}

const BOX = {w: 8, h: 5.4}
const HUB = {w: 14, h: 6.6}
const ARROW = 2.2
const GAP = 0.8

// When things happen, in milliseconds
const UNTANGLE = 2000
const MOVE = 1500
const HUB_SHOWN = 2900
const CLEAN_AT = 3200
const SETTLED = CLEAN_AT + TANGLED.length * 60 + 500
const EVERY = 2800

const clamp = (t) => Math.min(Math.max(t, 0), 1)
const easeInOut = (t) => (t < 0.5 ? 4 * t * t * t : 1 - (-2 * t + 2) ** 3 / 2)
const easeOutBack = (t) => 1 + 2.4 * (t - 1) ** 3 + 1.4 * (t - 1) ** 2

const element = (tag, attributes, parent) => {
  const el = document.createElementNS(SVG, tag)
  for (const [name, value] of Object.entries(attributes)) el.setAttribute(name, value)
  parent.appendChild(el)
  return el
}

// How far it is from the middle of a box to its edge, heading in the direction (ux, uy)
const reach = ({w, h}) => (ux, uy) => Math.min(w / 2 / Math.max(Math.abs(ux), 1e-6), h / 2 / Math.max(Math.abs(uy), 1e-6))
const boxReach = reach(BOX)
const hubReach = reach(HUB)

const unit = (dx, dy) => {
  const length = Math.hypot(dx, dy) || 1
  return [dx / length, dy / length]
}

// An arrow from one point to another, bent to one side by `bend`, leaving the box it starts in
// and stopping where the arrowhead's tip touches whatever it ends at.
function arrow([x1, y1], [x2, y2], bend, endReach) {
  const length = Math.hypot(x2 - x1, y2 - y1)
  const [ux, uy] = unit(x2 - x1, y2 - y1)
  const cx = (x1 + x2) / 2 - uy * bend * length
  const cy = (y1 + y2) / 2 + ux * bend * length

  const [sx, sy] = unit(cx - x1, cy - y1)
  const [ex, ey] = unit(x2 - cx, y2 - cy)
  const start = boxReach(sx, sy) + GAP
  const end = endReach(ex, ey) + GAP

  const tip = [x2 - ex * end, y2 - ey * end]
  const lineEnd = [tip[0] - ex * ARROW * 0.8, tip[1] - ey * ARROW * 0.8]

  return {
    d: `M ${(x1 + sx * start).toFixed(2)} ${(y1 + sy * start).toFixed(2)} Q ${cx.toFixed(2)} ${cy.toFixed(2)} ${lineEnd[0].toFixed(2)} ${lineEnd[1].toFixed(2)}`,
    head: `translate(${tip[0].toFixed(2)} ${tip[1].toFixed(2)}) rotate(${((Math.atan2(ey, ex) * 180) / Math.PI).toFixed(1)})`,
    start: [x1 + sx * start, y1 + sy * start],
    tip,
  }
}

function edge(parent, className) {
  const group = element("g", {class: className}, parent)
  const line = element("path", {class: "hg-line", pathLength: 1}, group)
  const head = element("path", {class: "hg-head", d: `M 0 0 L ${-ARROW} ${-ARROW / 2} L ${-ARROW} ${ARROW / 2} Z`}, group)
  return {group, line, head}
}

function draw({line, head}, geometry, progress) {
  line.setAttribute("d", geometry.d)
  line.style.strokeDashoffset = 1 - progress
  head.setAttribute("transform", geometry.head)
  head.style.opacity = progress > 0.92 ? 1 : 0
}

// Restarts a CSS animation on an element.
function replay(el, className) {
  el.classList.remove(className)
  void el.getBoundingClientRect()
  el.classList.add(className)
}

// `still` draws it as it ends up, with a signal on its way out, for the social card.
export function heroGraph(root, {still = false} = {}) {
  const reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches
  const svg = element("svg", {viewBox: "-50 -50 100 100"}, root)

  const defs = element("defs", {}, svg)
  const halo = element("radialGradient", {id: "hero-halo"}, defs)
  element("stop", {offset: "0", "stop-color": "#FF914D", "stop-opacity": "0.3"}, halo)
  element("stop", {offset: "1", "stop-color": "#FF914D", "stop-opacity": "0"}, halo)

  const tangleLayer = element("g", {class: "hg-tangle"}, svg)
  const cleanLayer = element("g", {class: "hg-clean"}, svg)
  const hub = element("g", {class: "hg-hub", transform: `translate(${HUB_AT[0]} ${HUB_AT[1]})`}, svg)
  const scaled = element("g", {class: "hg-hub-scale"}, hub)
  element("circle", {class: "hg-halo", r: 15}, scaled)
  const core = element("rect", {class: "hg-core", x: -HUB.w / 2, y: -HUB.h / 2, width: HUB.w, height: HUB.h, rx: HUB.h / 2}, scaled)
  const nodeLayer = element("g", {}, svg)
  const pulseLayer = element("g", {}, svg)

  const tangle = TANGLE.map(([from, to], index) => ({
    from,
    to,
    index,
    ...edge(tangleLayer, CYCLES.has(`${from}-${to}`) ? "hg-edge is-cycle" : "hg-edge"),
  }))
  const clean = TANGLED.map(() => edge(cleanLayer, "hg-edge"))

  const nodes = TANGLED.map(() => {
    const group = element("g", {class: "hg-node"}, nodeLayer)
    element("rect", {x: -BOX.w / 2, y: -BOX.h / 2, width: BOX.w, height: BOX.h, rx: 1.4}, group)
    return group
  })

  const positions = TANGLED.map((point) => [...point])
  const toHub = (index) => arrow(positions[index], HUB_AT, 0, hubReach)

  // Everything at `t` milliseconds in
  const render = (t) => {
    TANGLED.forEach(([x, y], index) => {
      const moved = easeInOut(clamp((t - UNTANGLE - index * 40) / MOVE))
      // Until they've moved, the modules strain a little against each other.
      const strain = (1 - moved) * 0.8
      const tx = x + Math.sin(t / 650 + index * 1.7) * strain
      const ty = y + Math.cos(t / 820 + index * 2.3) * strain
      positions[index] = [tx + (CLEAN[index][0] - tx) * moved, ty + (CLEAN[index][1] - ty) * moved]

      nodes[index].setAttribute("transform", `translate(${positions[index][0].toFixed(2)} ${positions[index][1].toFixed(2)})`)
      nodes[index].style.opacity = clamp((t - index * 60) / 400)
    })

    const fading = 1 - clamp((t - UNTANGLE) / 900)
    tangleLayer.style.opacity = fading
    tangleLayer.style.display = fading > 0 ? "" : "none"

    if (fading > 0) {
      for (const {from, to, index, ...parts} of tangle) {
        const geometry = arrow(positions[from], positions[to], index % 2 ? 0.2 : -0.2, boxReach)
        draw(parts, geometry, clamp((t - 150 - index * 45) / 500))
      }
    }

    const shown = clamp((t - HUB_SHOWN) / 500)
    scaled.style.opacity = shown
    scaled.style.transform = `scale(${0.4 + 0.6 * easeOutBack(shown)})`

    clean.forEach((parts, index) => draw(parts, toHub(index), clamp((t - CLEAN_AT - index * 60) / 500)))
  }

  if (still || reducedMotion) {
    render(SETTLED)
    if (still) {
      // Partway out from the contract to every module that listens
      nodes[EMITTERS[0]].classList.add("is-lit")
      nodes.forEach((node, index) => {
        if (EMITTERS.includes(index)) return
        const {start, tip} = toHub(index)
        element("circle", {class: "hg-pulse", r: 1.1, cx: tip[0] + (start[0] - tip[0]) * 0.55, cy: tip[1] + (start[1] - tip[1]) * 0.55}, pulseLayer)
      })
    }
    return
  }

  // A signal from one module, into the contract, and out to every module that listens
  let visible = true
  new IntersectionObserver(([entry]) => (visible = entry.isIntersecting)).observe(root)

  const travel = (from, to, duration, arrived) => {
    const dot = element("circle", {class: "hg-pulse", r: 1.1}, pulseLayer)
    const start = performance.now()
    const step = (now) => {
      const t = easeInOut(clamp((now - start) / duration))
      dot.setAttribute("cx", from[0] + (to[0] - from[0]) * t)
      dot.setAttribute("cy", from[1] + (to[1] - from[1]) * t)
      if (t < 1) return requestAnimationFrame(step)
      dot.remove()
      arrived()
    }
    requestAnimationFrame(step)
  }

  let turn = 0
  const emit = () => {
    if (visible && !document.hidden) {
      const from = EMITTERS[turn]
      replay(nodes[from], "is-hit")
      const {start, tip} = toHub(from)
      travel(start, tip, 650, () => {
        replay(core, "is-hit")
        nodes.forEach((node, index) => {
          if (EMITTERS.includes(index)) return
          const out = toHub(index)
          travel(out.tip, out.start, 800, () => replay(node, "is-hit"))
        })
      })
      turn = (turn + 1) % EMITTERS.length
    }
    setTimeout(emit, EVERY)
  }

  const began = performance.now()
  const frame = (now) => {
    const t = now - began
    render(t)
    if (t < SETTLED) return requestAnimationFrame(frame)
    setTimeout(emit, 600)
  }
  requestAnimationFrame(frame)
}
