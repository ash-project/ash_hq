+++
title = "Concentrated Liability"
description = "On the security issues from a recent audit of Ash, and why a framework like Ash is both a concentrated liability and a safety net."
date = 2026-10-15T12:00:00Z
authors = ["Zach Daniel"]

[taxonomies]
tags = ["ash"]
+++

Peter Ullrich recently ran a massive AI driven security audit on Ash Framework and its package ecosystem. We’re still working through the “fringe” packages, but all of the issues for the headliners have been shared and patched.

Given the theme of vulnerabilities, I’m going to lead with some of my own, personal in nature. One of the hard parts of dealing with security issues is a combination of the urgency (we care deeply about our users’ security, and our users’ users security) and the effort to resolve. For me, however, that is not the hardest part.

The hardest part for me is that this shit is embarrassing. People trust me. They trust our team. Not only to build tools that help them build their own applications, but to have thought through our architecture and code in such a way that they can sleep sound at night knowing that they made a good choice of framework. When I get a security issue report, it feels like I’ve betrayed that trust.

In practice, this just isn’t true. But that doesn’t change how it feels. It doesn’t change the way my stomach drops bottom when I see GHSA (GitHub Security Advisory) in my notifications list. I don’t know in practice how valuable it is for our users to know what it feels like for us, or how much they really need to care, but in an age of AI writing, I thought it might be good to lead with something human, something real.

---

Ash Framework is not a library (I mean, the name makes it pretty clear). Ash does so many high level things for you that naming them all would be longer than this post by a country mile. I sometimes joke that “Ash is the highest-code low-code framework that exists.” In a typical Ash application, you are defining some behavior in a condensed way, and your APIs, database operations, validations, even authorization logic, are handled by the framework. Our motto is “Model your domain, derive the rest.” You get superpowers from this methodology by virtue of the core framework doing all sorts of clever things for you, sometimes for convenience, sometimes for security, and most often for just pure, raw, capability.

What this means is that in our users’ applications Ash’s involvement starts right at the edge, going all the way down to the database and ending at the response to the user. All the while it handles automations, side-effects, time-based triggers, you name it. So in practice, your code is this tiny little powerful nugget of description that is expanded into an entire application layer’s worth of behavior.

It also means that one line of code does the work of hundreds or thousands of lines of code had it been hand-written, or composed out of a bunch of libraries. Ash provides both authentication and authorization primitives. You describe your rules and Ash implements authorization to a level of fidelity that for most teams it is just not practical to reproduce.

So when we have a bug in some internal tool or mechanism, one can almost always make the case that it constitutes a “security vulnerability”. The various parts of Ash are all interlinked, working together to accomplish a described outcome. It’s less wishy washy than I’m making it sound, it’s all declarative, deterministic code.

For example, let’s say there was an issue with applying a certain kind of filter under a very specific set of circumstances, where a filter might end up negated, i.e. `a == b` became `a != b` (this was not one of the vulnerabilities we addressed). If you were just using it as a library to run queries (which you could) it might look like this

```elixir
query
|> Ash.Query.filter(admin == true)
|> Ash.read!()
```

You’d get incorrect results, but in some tightly scoped area of usage. The data on a page might be displayed incorrectly, or some validation/authorization check in your application might fail. And if that was all that Ash was, you’d almost certainly not see a CVE come from us discovering that bug. We would just fix it and push a new bug fix release. Except that is not all that Ash is.

Here is an example policy for reading data from a resource in Ash.

```elixir
policy action_type(:read) do
  authorize_if actor_attribute_equals(:is_admin, true)
  authorize_if expr(published == true)
end
```

The rule this is describing is that you can read records of this resource if you are an admin, otherwise, you can read records where they have the attribute `published` set to true. In more common terms, you can see all rows of this database table if you are an admin, or if not, you can see rows where `published == true`.

Stepping one level up, you could then do something like this:

```elixir
actor = %User{is_admin: true}

Ash.read!(Post, actor: actor)
# SELECT * FROM posts;
```

If you ran the above function, you’d get all of the data in the table. If you ran the following code, some “magic” would happen:

```elixir
actor = %User{is_admin: false}

Ash.read!(Post, actor: actor)
# SELECT * FROM posts WHERE published IS TRUE;
```

Ash takes the policies, figures out what facts are true or false, determines if you can possibly make the request at all, and if you can, it will determine whether or not a filter needs to be applied to only return the data visible to the actor running the request.

Except it doesn’t stop there. In many usages of Ash, you won’t see the above code at all. Instead, you’d just see something like this:

```elixir
json_api do
  type "posts"

  routes do
    index "/posts", action: :read
  end
end
```

This translates roughly to:

- Create a route at `/posts` (a full-featured, spec-compliant JSON:API endpoint)
- When that route is called, translate the query arguments and/or body to a call to the `:read` action on this resource, using the current user as the actor
- Call that action with the correct inputs
- Take the response and format it for display over the API
- Display that result to the end user

We’re taking what is often hundreds or thousands of lines of code and boiling it down to practically one line (`index "/posts", ...`). This is awesome. It is wildly powerful in terms of both how much you get for free, how quickly you get it, and how secure it is. There is no way to “forget” to apply policies, or to somehow fail to honor the rules of the resource you are calling.

But it also means that if `Ash.Query.filter(admin == true)` is broken, then (at least theoretically) all kinds of other things are broken along with it.

---

This pattern plays out across a huge array of integrated features. Ash handles multitenancy for you, either via “attribute based” multitenancy (think an `organization_id` column), or “context based” multitenancy (schema-per-tenant in postgres). The tenant is automatically applied to every part of your query. Which may not sound that impressive until you understand how many other integrated features the tenant is automatically applied to. So if filters are broken, so might your tenant isolation be broken. Or if we fail to properly apply the tenant in some edge-case in our query builder, you may very well not notice.

Which, coincidentally was one of the CVEs that was raised in this audit. [GHSA-ww8j-58rc-f8h3: Cross-tenant information disclosure in `AshSql.AggregateQuery` in AshSql drops the query prefix when aggregating over a distinct query](https://github.com/ash-project/ash_sql/security/advisories/GHSA-ww8j-58rc-f8h3) showed that when you used `Ash.aggregate` to get an aggregate result (i.e. “count of X where Y”), in some cases we might drop the tenant. That’s the kind of thing that, even when tested, you might never really discover unless you intentionally thought “let me write a test where I create multiple tenants with data, and prove that the aggregate value returned only contains one tenant’s data”. The lack of that test is how we didn’t catch it, after all. For most people, they would call that type of test “testing the framework” and conventional wisdom would tell you not to do that.

The list goes on. Ash handles pagination for you. Which means any issues applying limit or offset (which didn’t happen) could produce incorrect query results. Ash handles pubsub notifications for you, which means any issues constructing topics or events could send information to the wrong place (which kind of but probably never actually happened).

Ash provides pre-built validations and transformations for you, which also produce error messages that get sanitized at the edge. Unless the error message contains incorrect or privileged information in place designed to be shown to end-users. Which did happen. In this example, if you said:

```elixir
destroy :delete_project do
  argument :confirm_secret_code, :string
  validate confirm(:secret_code, :confirm_secret_code)
end
```

The action will fail if the provided `confirm_secret_code` does not match the record’s `secret_code`. The error message, in one specific case, would come back containing the actual `secret_code` instead of the `confirm_secret_code` that you provided. Ash has some cool features that ensure we don’t leak sensitive data, for example:

```elixir
attributes do
  ...
  attribute :secret_code, :string, sensitive?: true
end

# and

destroy :delete_project do
  argument :confirm_secret_code, :string, sensitive?: true
  validate confirm(:secret_code, :confirm_secret_code)
end
```

In which case the value itself is redacted (replaced with `"**redacted**"`). But the issue is that we used the `sensitive?` configuration from the argument to decide if we should redact the value, and displayed the value in the attribute. So in this case, if the argument was not sensitive (which maybe it isn’t) but the attribute is then we’ve exposed a sensitive value in an error message.

Here again you see a bunch of useful framework features that, in concert, make your application significantly more secure. Except when we do it wrong.

---

The hard thing to internalize as a maintainer of a framework like this is that this is still better than whatever 99% of projects would hand roll. What I mean by this is that we (I) take a pretty brutal ego hit when these security issues come through, but we’ve still contributed to thousands of applications being wildly more secure than they ever would have been without us.

I’ve created something that is both a “concentrated liability” and a “safety net” all in one go.

These bugs exist everywhere, even in carefully crafted projects with hundreds of contributors and rigorous code review, and I can tell you with certainty after seeing the results of both open source vulnerability scanning and enterprise-grade vulnerability scanning: every application is riddled with these issues. In OSS, these become CVEs that (if the team is good and still maintaining it) are patched, users are alerted, and the world gets a bit safer. In your own code, they are just “bugs”. Who would tell you about them if you aren’t paying for a security audit?

The framing here could easily come off as me attempting to protect the image of Ash, but I really do believe that end users should carefully consider the above trade-offs. We’re going to be experiencing an onslaught of AI era vulnerability exploits, and we all need to make the right decisions for us.
