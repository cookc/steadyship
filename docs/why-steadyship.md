# Why Steadyship

You have built something useful by talking to Claude. A job board, a quote
builder, a parts list. It works, people in the business use it, and it took
an afternoon instead of a quote from a software company.

Then it starts to matter. Someone relies on it. A second person builds
something that overlaps with it. A number in one app disagrees with the
spreadsheet. You ask Claude for one more change and something else stops
working. And nobody in the building can say whether the thing is actually
good enough to run the business on, or what it would take to make it so.

Steadyship exists for that moment. It is like having an engineer working
with you, always.

## Does any of this sound familiar?

- The same information is typed into two apps and a spreadsheet, and they
  drift apart.
- An app keeps its data in the browser on one computer. If that machine
  goes, so does the data.
- Nobody owns an app. The person who built it has moved on, or forgot how
  it works.
- You cannot tell whether what Claude built is good, risky or fragile. It
  looks fine. It usually is fine, until it isn't.
- You have no idea who can see an app, or where what people type into it
  ends up.
- You built something that an app you already pay for could have done.
- Every new app makes the pile a little bigger, and nobody can see the bill
  coming.

None of this is a failing of Claude. Claude builds what it is asked to
build. The missing piece is the question nobody knew to ask, and the opinion
nobody was there to give.

## What an engineer brings

Steadyship is an add-on for Claude that behaves like an engineer sitting in
the conversation with you. It does the three things an engineer does.

**It asks what you don't know to ask.** When you ask for a change, it has
already read your business notes, your other apps and your spreadsheets. So
it asks the one or two questions that would be expensive to get wrong.
Should this attach to the whole job, or to each step inside it? Where should
this live so the rest of the team can see it? Isn't this already kept in
the price list on the shared drive? It recommends an answer, you decide,
and it builds. Never a questionnaire, never more than two questions.

**It judges what you can't judge.** Ask it to review an app and it says, in
plain words, whether the team can rely on it: Yes, No or Not yet, in the
first line. It names what would break, what data is at risk, and what would
need to change. It puts security in plain words: who can see this, where
what people type ends up, whether a password is sitting in a file, whether
the shared drive is open to anyone with the link. Every claim cites what it
checked. Anything it could not verify is labelled as such, never waved
through. A separate reviewer checks the first one, and for a business that
wants the strongest check, a reviewer from a different AI vendor, so it does
not share the builder's blind spots.

**It brings engineering when it's needed, not before.** A prototype stays
a prototype. The day someone relies on it, it gets looked after like
software: its data in one shared, backed-up place with one writer; a home
that isn't someone's laptop; a check that it still works; a named owner;
its decisions written down. Step by step, with a review at each step, not
a rebuild. Each step comes with one plain line on why it is worth it, and
more if you ask.

## The path

Every app is at one of four stages, and Steadyship says which.

| Stage | What it looks like | Moves on when |
|---|---|---|
| Prototype | One file, one person's tool | someone else starts using it |
| Owned tool | Shared, backed-up data with one writer; a test; a named owner | two apps touch the same information |
| Proper app | A real framework, shared parts, data checked on the way in | the business depends on it daily |
| Platform | Several apps on one database, kept in step | they must stay consistent for the business to run |

You never choose a framework, a database or a host. When an app has
reached the point where it should move on, Steadyship says so, gives the
reason, and offers to do it now or later. The decision is recorded either
way. An app's label changes only when the evidence does.

## Apps that stay in step

The pile stops growing when every app reads the same master. Steadyship
finds where the same price, job or customer is typed into two apps and a
spreadsheet, shows where they already disagree, and points every app at the
one file that is the real master. A shared glossary with a human owner
says what a "job" is, how its number is written and what the stages are
called, and every new piece of work is checked against it.

## It checks the ground before anyone builds on it

Most of what goes wrong with home-made apps is not the code; it is the
setup around it. The shared drive that turns out to be read-only from one
PC. The app that only ever worked on the laptop it was built on. So one
prompt, "Check this computer", runs three one-minute checks: can it reach
GitHub from here, can it read and write the shared drive your apps depend
on, can it open one of your apps and tell you whether it works. Each ends
in a plain PASS, FAIL or SKIP, and the answers are written down. A FAIL is
the problem found at minute one instead of month three.

## It stays out of the way

An engineer who slows everyone down gets ignored. So Steadyship keeps to a
few habits.

- **Short answers.** A reply is the first screen: what it found, the three
  things that matter, what it would do first. Say "show me everything" or
  "more" for the rest. The full detail is always written into the folder.
- **One plain line for anything it adds.** A library, a test, a shared
  file: each comes with one sentence on why it is worth it, and more if you
  ask. You should never be left thinking "it used to be faster, why is it
  doing all this now?"
- **No terminal, no Git to learn.** The folder is a repository underneath,
  but nobody in the business has to know that. Steadyship commits from a
  state you have approved.
- **It never blocks a prototype.** Exploring something? Build as you do
  today. It asks at most once, and only when the answer would be expensive
  to get wrong.

## What it looks like day to day

You say: "Make the job board track hours."

Steadyship says: "Your build guide lists three steps under Assembly and says
time is booked per step. Should hours be recorded against the whole job, or
against each step? I'd record per step, so you can see where the time goes.
Nothing has been changed yet; I'll build it as soon as you answer."

You say: "Each step." It records that decision, builds it, and tells you
where the hours are now stored and what that means.

Later you say: "Review the job board." It replies with a verdict, the
evidence, and the two things that would move it from Prototype to Yes.

## What you keep

- **A folder of your own.** Ordinary files, readable by anyone, in a
  private repository the business owns. Nothing is stored anywhere else.
- **It works without Steadyship.** Remove the add-on tomorrow and everything
  it wrote is still there and still useful. You are never worse off for
  having used it.
- **An honest answer.** If the right call is "don't build this, use the tool
  you already pay for", it says so. That is Steadyship working, not failing.
- **Nothing leaks.** Repositories it creates are private, and it refuses to
  push to one that is not. Passwords, secrets and large files never enter
  the folder. Whether business data may go to a cloud session is your
  call, asked once and recorded.

## What it is not

Steadyship is not a place to host apps, not a database, and not a
replacement for Claude. It does not stop you prototyping; it stays out of
the way until something matters. It is not a certificate that an app is
secure; it tells you what it checked and what it could not.

## Who it is for

A business where a few people who are not developers build their own tools
with Claude, and where those tools are starting to matter. One person holds
the accounts and does a one-off setup. The owner or a manager decides what
the business relies on. Everyone else just keeps building, with an engineer
in the conversation.

## Getting started

About ten minutes: the [quick start](../README.md#quick-start) has a page
for each setup (Windows or Mac, Claude desktop or Claude Code) that walks
through installing the add-on and setting it up for your business.
