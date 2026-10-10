# Developing ash-hq.org

How the site fits together, which pieces to reach for, how to make everyday changes, and the gotchas we've already hit.

- [Running and testing](#running-and-testing)
- [How it fits together](#how-it-fits-together)
- [Principles](#principles)
- [Components: which to use when](#components-which-to-use-when)
- [CSS](#css)
- [JavaScript](#javascript)
- [Everyday changes](#everyday-changes)
- [Tera 2 gotchas](#tera-2-gotchas)
- [Edge functions and redirects](#edge-functions-and-redirects)
- [Deploying](#deploying)

## Running and testing

```sh
zola serve --drafts --extra-watch-path data --extra-watch-path highlighting   # http://127.0.0.1:1111
deno test --allow-read tests/
```

- `--drafts` builds the draft [styleguide](http://127.0.0.1:1111/styleguide/): every component in one place, for checking changes. It's never published.
- `--extra-watch-path` reloads when files in `data/` (content) and `highlighting/` (the syntax theme and grammars) change. Zola doesn't watch either by default.
- `zola check --drafts --skip-external-links` builds the site and checks internal links.

The tests need Deno; the scripts in `scripts/` need `curl` and `jq`. Nothing needs Node or npm.

## How it fits together

| Folder | What's in it |
|---|---|
| `content/` | Pages and the blog, in Markdown with TOML front matter |
| `data/` | Structured content: events, the installer's options, the feature tour, packages, logos, the community's channels and core team |
| `templates/` | `base.html` (every page's layout), page templates, `partials/` (header, footer, event bar) and `components/` (one component per file) |
| `sass/` | The stylesheet: plain CSS partials, one per component, bundled by Zola into `/site.css` |
| `static/` | Served as-is: fonts, images, scripts in `js/`, the standalone Temporal Resources article and the talk deck |
| `icons/` | Lucide icons, inlined into pages by the `ui.icon` component |
| `highlighting/` | The syntax highlighting theme and the `iex` grammar |
| `netlify/` | Edge functions: the installer scripts and the old docs redirects |
| `scripts/` | Fetching the contributors, and building the docs redirect table |
| `tests/` | Deno tests for the edge functions and the installer's commands |

The design comes from the "Ash HQ" project in Claude Design. Its tokens (colours, type, spacing) are in `sass/_tokens.scss`; its components were rebuilt here as Tera components and CSS.

## Principles

- **Accessibility is not optional.** Every text colour meets WCAG AA (4.5:1) against every surface, and controls' edges meet 3:1 (`--border-control`). Use semantic elements, give everything a visible focus state, keep pages working without JavaScript, and announce dynamic changes in a live region.
- **No `style` attributes in templates, ever.** Not even for custom properties. Set them in the CSS of the class that uses them, or add a named modifier (`cards--wide`, `avatar--lg`).
- **Reuse before writing.** Check `templates/components/` and `sass/` for an existing pattern first. The second time something appears, extract it rather than copying it.
- **Check copy against its source.** Content ported from the old site (on the `main` branch) stays word for word. Copy from the design can be invented, so check it against `main` before using it.

## Components: which to use when

Components are in `templates/components/`, one per file, each documented at the top. They're called like JSX:

```jinja
{{ <ui.button text="Install Now" href="/installer/" size="lg" icon_right="arrow-right" /> }}

{% <ui.section title="Core Team" layout="split"> %}
  …content…
{% </ui.section> %}
```

### Page structure

| Component | Use it for |
|---|---|
| `ui.section` | **Every section of every page.** `plain` (the default), `band` (a spotlight, at most two per page, never adjacent) or `accent` (the page's one key action). `stack` or `split` (a sticky heading column). A page's first section takes `size="lg" heading="h1"`. Consecutive plain sections get a divider automatically. |
| `ui.section_header` | A section heading on its own, outside a section |
| `page.html` (a template) | Any page that's just Markdown: its title and description as the heading, its content as prose |

### Lists of things

| Component | Use it for |
|---|---|
| `ui.list_row` | Things over time or in sequence: posts, events, podcasts, contributors. Goes in a `<ul class="list-rows">`. A `lead` (a date or avatar) stays beside the content on small screens. |
| `ui.card` | A set to browse: articles, channels, packages (`compact`). Goes in a `<ul class="cards grid">`. |
| `ui.person` | People, linking to their GitHub profile. Goes in a `<ul class="people grid">`. |
| `ui.contributor_of_the_month` | A contributor of the month, as a list row linking to their certificate |

Linked rows, cards and person tiles are clickable as a whole, but only their title is the link (`.stretched-link`), so screen readers announce a short link name.

### Actions and links

| Component | Use it for |
|---|---|
| `ui.button` | Buttons, and links styled as buttons (pass `href`). One `primary` per section; `secondary`, `ghost` and `link` for the rest. Icon-only buttons need a `label`. Put several in a `<div class="button-row">`. |
| `ui.announcement` | The one "New" link near the top of the home page |
| `ui.event_bar` | The bar above the header, rendered automatically for the next event |

Links that open in a new tab (`new_tab` on Button, Card and ListRow) tell screen reader users so with `ui.new_tab_note`. Use them for links that leave the site to be read alongside it, such as package docs and podcasts, not as a default.

### Text and media

| Component | Use it for |
|---|---|
| `ui.callout` | A note, tip or warning in an article. At most one or two per article. |
| `ui.figure` | An image in an article that's linked, captioned or `small` (covers, logos) |
| `ui.code_block` | Highlighted code from a template, with a filename, line numbers and highlighted lines |
| `ui.terminal` | A shell command |
| `ui.video` | A YouTube video or playlist, from youtube-nocookie.com |
| `ui.badge`, `ui.eyebrow` | Tags and types (`badge`); dates, months and other metadata labels (`eyebrow`) |
| `ui.date_badge` | A date as a small calendar page, for events and posts |
| `ui.avatar`, `ui.author_avatars` | Avatars from GitHub, in sizes `xs` to `xl`; blog authors' avatars from `extra.authors` in `zola.toml` |
| `ui.icon` | Any icon. Decorative: the text beside it carries the meaning. |

### Interactive

| Component | Use it for |
|---|---|
| `ui.tabs` and `ui.tab_panel` | Tabbed panels: `underline` tabs, or `steps` (the feature tour). Without JavaScript the panels show in turn. The selected tab goes in the URL hash. |
| `ui.segmented` | A choice of a few options, as native radios (the installer's New Project or Existing App) |
| `ui.option_chip` | Toggle buttons with tooltips (the installer's presets and features) |
| `ui.input` | A text input with its label (`hide_label` keeps it for screen readers only) |
| `ui.tour_result` | A feature tour step's result panel |

### Using components in Markdown

Content is a Tera template too, so components work in Markdown:

```markdown
{% <ui.callout title="A strangely necessary foreword:"> %}
This message was not built by or with the use of any ML algorithms.
{% </ui.callout> %}

{{ <ui.figure src="/images/book-cover.jpg" alt="…" size="small" /> }}
```

- **The body isn't parsed as Markdown:** use HTML for links or emphasis inside it.
- **Components used in Markdown must trim the whitespace at their start** (`{% component … -%}`). An indented line straight after a list is read as part of the list's last item.
- **Leave a blank line before and after** a component in Markdown.
- Literal `{{` or `{%` in content (in a code sample, say) needs wrapping in `{% raw %}…{% endraw %}`.

## CSS

- **One partial per component** in `sass/`, plus `site.scss`, which `@use`s them in order. The partials are plain CSS; Sass only bundles them.
- **Cascade layers** set precedence: `tokens`, `base`, `layout`, `components`, `utilities` (see `_layers.scss`). Later layers win, so `!important` is never needed, with two deliberate exceptions in `_base.scss`: reduced motion, and `[hidden]`, which always hides.
- **Use the tokens.** Colours, type, spacing and motion are custom properties in `_tokens.scss`. Use the semantic aliases (`--text-muted`, `--surface-accent`), not the raw ramps.
- **Layout primitives** in `_layout.scss`: `.container`, `.grid` (configured by `--min`, `--col-gap` and `--row-gap`, set in the list's own CSS), `.split`, `.sidebar`, `.aside`, `.cols`, `.pair`, `.button-row`. Everything collapses to one column below 860px.
- **Shared patterns:** `.stretched-link`, `.quiet-link` (muted icon and label links), `.cta-label` (a decorative "Read more →" in a clickable item), `.visually-hidden`, `.hide-mobile` and `.only-mobile`.
- **Text colours are checked for contrast.** If you add a colour, check it reaches 4.5:1 against `--bg-page`, `--bg-subtle`, `--surface-raised`, `--surface-accent` and `--surface-code`.
- `sass/certificate.scss` is separate: the contributor certificates' own look, served as `/certificate.css` on those pages only.

## JavaScript

Small modules in `static/js/`, loaded only by the pages that need them, with no build step and no dependencies:

| Script | Does |
|---|---|
| `site-header.js` | The mobile menu toggle |
| `tabs.js` | Tabs and the feature tour's steps |
| `filter-list.js` | Filtering a list as you type (the Ecosystem page) |
| `installer.js` | The Installer page's options, using `installer-command.js` to build the command |

Pages must work without JavaScript: anything a script adds is hidden until the script runs (the `hidden` attribute, removed by the script), and content is always in the HTML.

## Everyday changes

### Icons

Icons are [Lucide](https://lucide.dev) icons, inlined from `icons/`. To add one, download it as published, then use it by name:

```sh
curl -fsS https://unpkg.com/lucide-static@0.468.0/icons/NAME.svg -o icons/NAME.svg
```

```jinja
{{ <ui.icon name="NAME" /> }}
```

Don't edit the SVGs: the component strips the licence comment and adds its own attributes. Keep to the same Lucide version, so icons match.

### Blog posts

Add a Markdown file to `content/blog/`, named for its URL:

```toml
+++
title = "Introducing Something"
description = "A one-line summary, shown in the blog's list and link previews."
date = 2026-10-03T11:40:12Z
authors = ["Zach Daniel"]
# Old URLs for the post, if it's been renamed
aliases = ["/blog/old-slug/"]

[taxonomies]
tags = ["ash", "release"]
+++
```

- Start headings at `##`: the post's title is the page's only `<h1>`.
- Give every image alt text (`alt=""` if it's decorative).
- New authors need their GitHub username in `extra.authors` in `zola.toml`, for their avatar.
- Posts are marked "New" for `extra.new_post_days` (30) after their date, automatically.

### Events

Add them to `data/events.toml` (the fields are described at the top). The next upcoming event shows in the bar above the header, and all upcoming ones on the Community page. Past events drop off by themselves when the site is rebuilt.

### Contributors of the month

Add a file to `content/community/contributors-of-the-month/`, named for their certificate's URL:

```toml
+++
title = "Their Name"
description = "Why they were recognized, shown on their certificate and in the hall of fame."
date = 2026-11-01  # any day in the month they were recognized
[extra]
github = "their-username"
+++
```

The newest is featured on the Community page. For the certificate's link preview image, open `/community/contributors-of-the-month/<slug>/?image=true` in a 1320×1020 window (US Letter, landscape), screenshot it, and save it as `static/images/contributors-of-the-month/<slug>.png`. Pages without one use the site's default image.

### Other content

| To change | Edit |
|---|---|
| Media page articles, podcasts, the YouTube playlist | `data/media.toml` |
| Ecosystem packages (the first eight are on the home page) | `data/ecosystem.toml` |
| Customer logos | `data/logos.toml`, with the image in `static/images/` |
| Community channels and core team | `data/community.toml` |
| The main navigation | `extra.nav` in `zola.toml` |
| The feature tour | `data/tour.toml`. When a step's code changes, check its `highlight` line ranges still point at the lines it adds. |
| Installer presets and features | `data/installer.toml`. Features are listed in install order. Run the tests afterwards: they check the generated commands. |
| Book errata | `content/book-errata.md` |

### Syntax highlighting

Code is highlighted by Zola, using the theme in `highlighting/ash.json`, written as classes into a generated `/giallo.css`. The theme takes hex colours only, so it duplicates the `--syn-*` tokens in `_tokens.scss`: change both together. Fence IEx sessions as ` ```iex ` to mute the prompt (`highlighting/iex.json`). With `--extra-watch-path highlighting`, `zola serve` picks up changes to either.

## Tera 2 gotchas

Zola 0.23 uses Tera 2, which differs from Tera 1 and from most examples online. The [Tera docs](https://keats.github.io/tera/) are for Tera 2.

- **Pass anything but a string literal in braces:** `size={size}`, `full={true}`, `tags={page.taxonomies.tags}`. `size=size` doesn't work.
- **`body` is undefined when a component is self-closed.** Check `body is defined` before using it.
- **`default` only replaces undefined values,** not `none`. A missing front matter field is often `none`: use `default(value="", boolean=true)`.
- **You can't read a field from a function call:** set the result first (`{% set data = load_data(…) %}`, then `data.items`).
- **Tests take keyword arguments:** `is starting_with(pat="/blog/")`.
- **Variables set in an include don't outlive it.** Shared values are set at the top of `base.html` (`upcoming_events`, for example).
- **Filters bind tighter than `~`:** `a ~ b | markdown` only renders `b`. Build the string into a variable first.
- **A backslash in a string literal starts an escape:** write `\\` for one.
- **Components are hermetic:** they only see their arguments. Use an implicit parameter (`@config`) for site config.
- There's no `slice` filter; use `loop.index` in a `for` loop instead.

## Edge functions and redirects

- **`netlify/edge-functions/installer.js`** serves the install scripts at `/new/:name` and `/install/:name`, as the old site did, byte for byte (`tests/installer/fixtures/`). Every value from the URL is checked against an allowlist, as the script is run by the shell.
- **`netlify/edge-functions/docs-redirect.js`** sends the old docs URLs under `/docs` to hexdocs, using `data/doc-modules.json`. Rebuild that with `scripts/fetch-doc-modules.sh` if old links to a newly added library stop resolving. Libraries are listed in `data/libraries.txt`, which the contributors script reads too.
- **Other redirects** (the old RSS feed, a renamed blog post, the retired forum) are in `netlify.toml`.

## Deploying

The site isn't live yet. `netlify.toml` has the build settings: Netlify fetches the contributors, then builds with Zola, for each deploy's own URL (`DEPLOY_PRIME_URL`), so links on test deploys stay on them. Set `GITHUB_TOKEN` in the site's environment variables, as Netlify's shared build servers can hit GitHub's limit for anonymous requests.

To deploy by hand, use the Netlify CLI from the repo root, with `--build`. That runs the build command from `netlify.toml` and bundles the edge functions; without it, the CLI only uploads `public/` as it is, with no edge functions.

Zola writes absolute URLs, for the base URL it builds with. The build command picks it for each kind of deploy (see the comments in `netlify.toml`): production deploys use the site's main address, and previews use their own.

```sh
# A production deploy
netlify deploy --build --prod

# A draft, to try something out: its address isn't known until it's uploaded, so build with
# root-relative URLs
ZOLA_BASE_URL=/ netlify deploy --build
```

Only use root-relative URLs (`/`) for drafts: canonical links, link previews and the feed need absolute URLs.

Uploading `public/` some other way skips the edge functions, and after only `zola serve`, `public/` holds just the static files: `zola serve` serves pages from memory.

Still to come: a scheduled rebuild every six hours, to keep the contributors and events current, and a CI workflow running the tests.
