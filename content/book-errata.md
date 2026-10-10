+++
title = "Ash Framework Book Errata"
description = "Last updated: 25 June 2026"
+++
Corrections and changes since publication for the [Ash Framework](https://pragprog.com/titles/ldash/ash-framework/) book.

- On **page 64** under the subheading "Searching from the Catalog", the reference to the `Tunez.Artists.IndexLive` should actually be `TunezWeb.Artists.IndexLive`
- On **page 74**, the function `AshPhoenix.LiveView.page_from_params` has been deprecated - the `page_params` definition should be replaced with `page_params = AshPhoenix.LiveView.params_to_page_opts(params, default_limit: 12)`
- On **page 94** (ebook only), the API URL with `include=albums` should not have an encoded ampersand - it should be `http://localhost:4000/api/json/artists/?query=cove&include=albums` (no `amp;`).
- On **page 109** under the heading "Setting Up Password Authentication", the generator now adds *three* new attributes to the `Tunez.Accounts.User` resource, including a new `confirmed_at` attribute
- On **page 113**, you no longer need to manually add the Tailwind configuration to `assets/css/app.css` - Igniter will do this for you automatically.
- On **page 126**, the default AshAuthentication installer will no longer add a `policy always()` block to the `Tunez.Accounts.User` resource. It no longer needs to be removed before adding a new policy for the register/sign-in actions (**page 127**).
- On **page 130-131**, you will no longer get an AshGraphql compilation error due to metadata on the `sign_in_with_password` action - the metadata will be dropped instead, similar to AshJsonApi.
- On **page 139-140**, the output of the policy breakdown is slightly different - the `authorize if: actor.role == :admin` line now has a ↓ instead of a 🔎, and the SAT solver statement is no longer printed.
- On pages **142-144** and **148-149**, references to modules to update should use `TunezWeb`, not `Tunez`.
- On **page 152**, you no longer need to add an extra policy to make `relate_actor` work (but the policy still makes sense anyway!)

{{ <ui.figure src="/images/book-beta.jpg" alt="The cover of Building Web Applications with Ash, by Rebecca Le and Zach Daniel" size="small" href="https://pragprog.com/titles/ldash/ash-framework/" /> }}

[Get the book!](https://pragprog.com/titles/ldash/ash-framework/)
