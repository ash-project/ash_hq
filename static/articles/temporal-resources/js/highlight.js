// A small syntax highlighter for the Elixir and SQL in the article.

const rules = {
  elixir: [
    ["c", /#[^\n]*/y],
    ["s", /"(?:\\.|[^"\\])*"/y],
    ["s", /~[a-zA-Z](?:\[[^\]]*\]|"[^"]*"|\([^)]*\))/y],
    ["key", /[a-z_][a-zA-Z0-9_]*[?!]?:(?=\s)/y],
    ["atom", /:[a-z_][a-zA-Z0-9_]*[?!]?/y],
    ["mod", /[A-Z][a-zA-Z0-9_]*(?:\.[A-Z][a-zA-Z0-9_]*)*/y],
    ["kw", /(?:do|end|fn|defmodule|defp|def|use|when|true|false|nil)\b/y],
    ["fun", /[a-z_][a-zA-Z0-9_]*[?!]?(?=\()/y],
    ["id", /[a-z_][a-zA-Z0-9_]*[?!]?/y],
    ["num", /\d+(?:\.\d+)?/y],
    ["op", /\|>|->|<-|==|!=|[=|&]/y],
  ],
  sql: [
    ["c", /--[^\n]*/y],
    ["s", /'(?:[^']|'')*'/y],
    [
      "kw",
      /(?:SELECT|FROM|WHERE|AND|OR|INSERT|INTO|VALUES|UPDATE|SET|DELETE|FOR|PORTION|OF|TO|NULL|CREATE|TABLE|PRIMARY|KEY|WITHOUT|OVERLAPS|NOT)\b/y,
    ],
    ["type", /(?:uuid|bigint|text|tstzrange)\b/y],
    ["id", /[a-zA-Z_][a-zA-Z0-9_]*/y],
    ["num", /\d+/y],
    ["op", /@>|[=*]/y],
  ],
}

const escape = (text) =>
  text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")

export function highlight(code, language) {
  const tokens = rules[language]
  let html = ""
  let plain = ""
  let position = 0

  while (position < code.length) {
    let matched = null

    for (const [kind, pattern] of tokens) {
      pattern.lastIndex = position
      const match = pattern.exec(code)
      if (match && match[0].length > 0) {
        matched = [kind, match[0]]
        break
      }
    }

    if (matched) {
      const [kind, text] = matched
      html += escape(plain)
      plain = ""
      html += kind === "id" ? escape(text) : `<span class="t-${kind}">${escape(text)}</span>`
      position += text.length
    } else {
      plain += code[position]
      position += 1
    }
  }

  return html + escape(plain)
}

// Highlights every code block, drawing attention to the lines in its `data-highlight`
// range, like `data-highlight="5-8"`, if it has one.
export function highlightAll(root = document) {
  for (const block of root.querySelectorAll("pre[data-lang] code")) {
    const {lang, highlight: range} = block.parentElement.dataset
    const html = highlight(block.textContent.replace(/^\n/, "").replace(/\s+$/, ""), lang)

    if (range) {
      const [first, last = first] = range.split("-").map(Number)
      block.innerHTML = html
        .split("\n")
        .map((line, index) => {
          const marked = index + 1 >= first && index + 1 <= last
          return `<span class="line${marked ? " is-highlighted" : ""}">${line || " "}</span>`
        })
        .join("")
    } else {
      block.innerHTML = html
    }
  }
}
