# Change Log

All notable changes to this project will be documented in this file.
See [Conventional Commits](Https://conventionalcommits.org) for commit guidelines.

<!-- changelog -->

## [v0.1.0](https://github.com/ash-project/ash_hq/compare/v0.1.0...v0.1.0) (2022-11-16)




### Features:

* DocSidebar: Extract TreeView component to improve consistency (#48)

* collapse sidebar sections (#32)

### Bug Fixes:

* don't use `live_redirect` anywhere because we care about the session

* Dark mode borders and scrollbars (#57)

* prevent strange behavior when scrolling from URL hash to elements near end of document

* broken pages due to bad replacement rendering

* make mobile blog at least usable

* Workaround morphdom incorrectly merging docs headings (#44)

* don't scroll sidebar based on main docs window scroll position

* account for not all resources being AshPostgres resources

* properly anchor link to options

* download user agent db in setup task (#39)

* remove flame on

* catalogue color issues

* perform `no_user_verify/0` on no user found

* use svg over png, smaller logos

* scrollable sidebar on mobile

* local deps/small things

* clicking on search result closes

* don't defer mermaid

* still some typos from `slate` -> `base` find & replace

* typos from find and replace

* Add color to select #21

* fix right nav links and scrolling

* fix right nav links and scrolling

* properly prefix module source links

* can't use LiveRedirect for some reason?

* properly check cookie consent status

* be GDPR compliant with cookie usage

* better formatted welcome link

* better spacing

* WIP on imports

* fix source links

* merge conflicts on ash versions

* fix setting theme in js

* set up api client for swoosh

* bamboo/swoosh were both in use/mixed up. Using swoosh

* use LiveRedirect vs LivePatch

* use name_attribute for name match rank

* overflow-auto instead of -scroll

* better latest version finding

* show docs properly

* set table headers properly

* update to latest ash

* make type limiting work on search again

* update ash

### Improvements:

* setup CI

* improve docs layout and scrolling behavior (#55)

* Sort guides by order field in DocSidebar (#50)

* make generated calculations private

* honor default guide configurations

* various fixes, support new spark links

* blog fixes, update to latest ash_graphql

* tons of improvements, add ash_blog

* add some basic graphql stuff

* various deployment/docs improvements

* fix string replacement to work in code blocks

* change key shortcut based on device brand

* close sidebar on navigate

* add list of dsl sections when viewing extension

* fix bad version rendering, show all relevant links in sidebar

* various UI improvements, new testimonial

* add more quotes

* show code snippets on mobile

* hide fields that are auto-set

* use new flow features for search

* use the new `Tails` library

* class lists

* find more modules

* color fixes

* various user-flow & email improvements

* tshirt mailer, mailing list

* encrypted-at-rest name and address

* enable user sign up/authentication again

* some mobile appearance on home page stuff

* add examples to docs

* add some basic html styling to the welcome email

* add bigger logo & Elixir to subtitle

* make the contribute link into a button

* update to latest dependencies

* add logos section

* add contributors section

* speed up page load by not loading functions

* sort versions properly in catalogue

* add library catalogue

* fix warnings

* update spark/surface, import only every 30 minutes

* remove import controller in favor of periodic imports

* periodic imports

* lots of docs fixes!

* add pg extensions

* keep everything open

* remove sidebar collapsing (maybe)

* monitoring/images/cleanup

* make `LivePatch` work again

* add some experimental class helpers

* fix various anchor & scroll issues

* add xCode stuff to the iOS folder

* add basic live view native, various other small fixes

* tweak theme and adjust landing page to match

* Convert default tailwind colors to custom themes

* keep content in the center of the screen on ultrawides

* Docs sizing and custom scrollbar

* spacing/mobile styling improvements

* improvem mobile docs styling

* fix unsubscribe

* hide more on mobile

* better search docs

* add mailing list

* WIP, add analytics

* various fixes, update deps

* small tweaks

* upgrade to ash 2.0

* disable debug and fix scrolling

* turn off debug

* add migrations update deps

* rework auth forms to liveview

* better look and feel (not much better, though)

* add logout button, settings button

* turn of csp

* add authorization to accounts

* get a build set up

* fix lint/security issues

* add CSP

* remove currently unnecessary/old code

* fix postmark api key config

* copy over example with auth to ash-hq

* theming

* click on headers to open

* fix item paths, make sidebar much friendlier

* huge optimization (hopefully) for memory usage/search performance

* larger docs in general

* table headers for options list

* more links

* add option links

* allow removing libraries

* flatten search results

* update to latest ash/ash_postgres, add indexes at the extension level

* show types in search item results

* render `default_guide`, ignore extension moduledocs

* new dsl link types

* comment sections to ignore in ash-hq

* WIP on importer/doc links
