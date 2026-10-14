import {heroGraph} from "./hero.js"
import {highlightAll} from "./highlight.js"
import {scrolly} from "./scrolly.js"
import {STATES as GRAPH_STATES, GraphView} from "./graph.js"
import {delivery} from "./delivery.js"

heroGraph(document.getElementById("hero-graph"))
highlightAll()

// What signals do to the arrows between the parts of an application
scrolly(document.getElementById("untangle"), new GraphView(document.getElementById("graph-visual")), GRAPH_STATES)

// Placing an order, with each listener inline or in jobs
delivery(document.getElementById("delivery"))
