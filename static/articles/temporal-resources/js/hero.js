// A great clock face turning slowly behind the title: rings of ticks and numerals, each
// at its own pace and some the other way round, and a hand sweeping by once a minute
// with a glow trailing behind it.

const SVG = "http://www.w3.org/2000/svg"

// Tick marks evenly around a dial, as one path, with every `longEvery`th tick longer.
function ticks(radius, count, longEvery, short, long) {
  let path = ""

  for (let tick = 0; tick < count; tick++) {
    const angle = (2 * Math.PI * tick) / count
    const length = tick % longEvery === 0 ? long : short
    const point = (r) => `${(r * Math.sin(angle)).toFixed(1)} ${(-r * Math.cos(angle)).toFixed(1)}`
    path += `M${point(radius)}L${point(radius - length)}`
  }

  return path
}

function svg(className, duration, children) {
  const el = document.createElementNS(SVG, "svg")
  el.setAttribute("viewBox", "-500 -500 1000 1000")
  el.setAttribute("class", className)
  el.style.animationDuration = duration
  el.innerHTML = children
  return el
}

export function dial(root) {
  const numerals = "XII I II III IV V VI VII VIII IX X XI"
    .split(" ")
    .map(
      (numeral, index) =>
        `<text transform="rotate(${index * 30}) translate(0 -370)" text-anchor="middle" dominant-baseline="middle" fill="#FFBD59" fill-opacity="0.3" font-size="34" font-family="ui-serif, Georgia, serif">${numeral}</text>`
    )
    .join("")

  root.append(
    svg(
      "dial",
      "360s",
      `<circle r="496" fill="none" stroke="#FF914D" stroke-opacity="0.18" stroke-width="2"/>
       <path d="${ticks(480, 120, 10, 10, 28)}" stroke="#FF914D" stroke-opacity="0.28" stroke-width="3" stroke-linecap="round"/>`
    ),
    svg(
      "dial dial-back",
      "240s",
      `<circle r="412" fill="none" stroke="#FFBD59" stroke-opacity="0.14" stroke-width="1.5"/>${numerals}`
    ),
    svg(
      "dial",
      "150s",
      `<path d="${ticks(300, 60, 5, 8, 20)}" stroke="#FF5757" stroke-opacity="0.25" stroke-width="2.5" stroke-linecap="round"/>
       <circle r="250" fill="none" stroke="#FF914D" stroke-opacity="0.18" stroke-width="2" stroke-dasharray="2 14"/>`
    ),
    svg(
      "dial dial-back",
      "90s",
      `<circle r="170" fill="none" stroke="#FF5757" stroke-opacity="0.2" stroke-width="1.5" stroke-dasharray="60 20 6 20"/>`
    )
  )

  const hand = document.createElement("div")
  hand.className = "dial dial-hand"
  hand.style.animationDuration = "60s"
  hand.innerHTML = `<div class="dial-glow"></div>
    <svg viewBox="-500 -500 1000 1000"><line x1="0" y1="24" x2="0" y2="-470" stroke="#FF914D" stroke-opacity="0.55" stroke-width="2"/><circle r="7" fill="#FF914D" fill-opacity="0.7"/></svg>`
  root.append(hand)
}
