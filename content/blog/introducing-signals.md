+++
title = "Introducing Signals"
description = "Let one resource react to another, without either depending on the other."
date = 2026-10-13T12:00:00Z
authors = ["Zach Daniel"]
# The article is interactive, so it's a standalone page rather than a Markdown post. Its
# assets live in static/articles/signals/. This body is what the feed shows.
template = "articles/signals.html"

[taxonomies]
tags = ["ash", "release", "signals"]
+++
Signals are new in Ash 3.36! They let one resource react to what happens in another, without either one depending on the other. A resource emits a typed signal, other resources listen for it with their own actions, and each listener decides whether it runs in the same transaction or in a background job.
