+++
title = "Ash Framework 3.0"
description = "Released!"
date = 2024-09-15T03:24:22Z
authors = ["Zach Daniel"]

[taxonomies]
tags = ["ash", "elixir", "release"]
+++
## Ash Framework 3.0: Official Release!

I'm here with the fine folks at [Gig City Elixir](https://www.gigcityelixir.com), pushing the button live on stage 😎 

<img src="/images/gig-city.jpg" alt="Zach on stage at Gig City Elixir, in front of a waving, cheering audience"></img>

The other packages around Ash will be updated with non-release candidate versions over the next few hours.

## What is changing?

While there are far too many things to put them all here, I want to give those who haven't been following along with our [3.0 teasers](https://elixirforum.com/t/ash-3-0-teasers/61857/1) an idea of where the focus is for Ash 3.0. There are three themes that cover most of the changes:

- **Security**: We want to make sure that Ash is safe and secure by default, and that it is free of foot guns that could lead to security issues, data consistency or other critical failures. Some examples of this are:
  - [Actions no longer accept all public attributes by default](https://elixirforum.com/t/ash-3-0-teasers/61857/28)
  - [All fields are now private by default](https://elixirforum.com/t/ash-3-0-teasers/61857/28#private-true-is-now-public-false-and-public-false-is-now-the-default-3)
  - [Authorization is always done by default](https://elixirforum.com/t/ash-3-0-teasers/61857/22#domainauthorizationauthorize-now-defaults-to-by_default-2)

- **Simplicity**: Ash is a huge ecosystem, and there is a lot to learn about how it works. Every confusing term and inconsistency increases the mental burden on developers, and increases the likelihood of bugs and wasted time. Some examples of this are:
  - [`Ash.Api` is now `Ash.Domain`](https://elixirforum.com/t/ash-3-0-teasers/61857/22#domainauthorizationauthorize-now-defaults-to-by_default-2)
  - [Not selected attributes show `%Ash.NotLoaded{}` instead of `nil`](https://elixirforum.com/t/ash-3-0-teasers/61857/28)

- **Developer Experience**: With 2.x versions adding support for atomics and bulk actions, the core functionality of Ash is in a very good place. This gives us the time and mental cycles to devote to developer experience. While many of the 3.0 changes are focused on DX, we also expect to see a much greater focus on this moving forward! Some examples of this are:
  - [Ash.ToTenant protocol](https://elixirforum.com/t/ash-3-0-teasers/61857/36)
  - [Custom Expressions](https://elixirforum.com/t/ash-3-0-teasers/61857/28#custom-expressions-4)
  - [Policies & Code Interfaces on the domain](https://elixirforum.com/t/ash-3-0-teasers/61857/30)

## How do I upgrade?

It is **very important** that you read and follow the [upgrade guide](https://hexdocs.pm/ash/3.0.0/upgrade.html)! You will need to go through it section by section and consider if there are changes from that section that you must make. Don't forget that some packages have their own upgrade guides for breaking changes contained in that package. Links to those guides are at the top.

## What if I need help?

If you encounter an issue or change that is not covered in the upgrade guide *please* contact us or open a PR to add to the guide. Even if it's just a note reminding folks to look out for something that might be a gotcha. Every little bit helps :)

Feel free to ask questions here on the forum if you need assistance!

### What about 2.x?

Ash 2.x will receive a **minimum** of 6 months of critical bug fixes and security upgrades. Critical bug fixes include issues that have no reasonable workaround. Security upgrades includes things like updating potentially vulnerable packages, or fixing any issues related to policies, authentication, etc. We won't be leaving folks in the dust, but it will absolutely be in your best interest to find a time in the next few months to upgrade, as there are many features in 3.0 to take advantage of and there are already more on the way!

And don't forget, the Ash book is coming! Keep an eye out for updates 🥳. Thanks again to @sevenseacat for all her fine work on this book, its coming along spectacularly.

<img src="/images/book-cover.jpg" alt="The cover of Building Web Applications with Ash, by Rebecca Le and Zach Daniel"></img>
