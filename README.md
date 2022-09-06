# AshHq

## Getting Started

1. Fork and clone this repository.
2. Set up the project by running `mix do deps.get, deps.compile, setup` (the import may take a while).
3. Install the frontend assets by running `npm i --prefix assets`.
4. Run the server with `iex -S mix phx.server`
5. Open [http://localhost:4000](http://localhost:4000)

## A Bit of History

The liveview part is not very conventional, I was focused on speed when I first wrote it, and it (as things always do) evolved from something far more simple. The truly complicated part is that the docs are _not_ static content like you would typically see for documentation. They are all stored in a database, because they can all be full-text searched using postgres. Eventually it would make sense to serve the individual doc pages from a CDN or something like that. The interesting pages in that regard is the `Docs` page. We do quite a bit of work to make sure that we are only loading the html that will be served for the exact document we are seeing.

The magic of search is done via `AshHq.Docs.Extensions.Search`, which modifies resources to make them full text searchable using postgres, amongst other things. See `lib/ash_hq/docs/extensions/search/transformers/add_search_structure.ex` for more.

There is also a usage of `Ash.Flow` for searching, which can be found in `lib/ash_hq/docs/search/search.ex`. It is actually a bit un-ideal, as the better thing to do would be to use a postgres UNION. There are ways to do that with Ash by extracting the resource queries and then making a union, but it was much easier to just put a search action in a flow. Eventually, Ash will support unions.
