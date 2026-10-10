# ash-hq.org

The website for [Ash Framework](https://github.com/ash-project/ash): a static site built with [Zola](https://www.getzola.org), with hand-written HTML and CSS, a little vanilla JavaScript and no Node.

The docs themselves live on [hexdocs.pm](https://hexdocs.pm/ash); this site redirects the old ash-hq.org docs URLs there.

## Running it

You'll need [Zola](https://www.getzola.org/documentation/getting-started/installation/) 0.23 or later, and [Deno](https://deno.com) for the tests.

```sh
zola serve --drafts --extra-watch-path data --extra-watch-path highlighting   # http://127.0.0.1:1111
deno test --allow-read tests/   # the installer scripts, install commands and docs redirects
```

Optionally, fetch the contributors shown on the Community page (needs `curl` and `jq`):

```sh
scripts/fetch-contributors.sh
```

## Working on it

See [DEVELOPING.md](DEVELOPING.md) for how the site fits together, which components to use when, how to do everyday content changes, and the gotchas.
