# Why Steadyship

You have built something useful by talking to Claude. A job board, a quote
builder, a parts list. It works, people in the business use it, and it took
an afternoon instead of a quote from a software company.

Then it starts to matter. Someone relies on it. A second person builds
something that overlaps with it. A number in one app disagrees with the
spreadsheet. You ask Claude for one more change and something else stops
working. And nobody in the building can say whether the thing is actually
good enough to run the business on, or what it would take to make it so.

Steadyship exists for that moment. It is the engineer who would have been
sitting beside you if the business had one.

## Does any of this sound familiar?

- The same information is typed into two apps and a spreadsheet, and they
  drift apart.
- An app keeps its data in the browser on one computer. If that machine
  goes, so does the data.
- Nobody owns an app. The person who built it has moved on, or forgot how
  it works.
- You cannot tell whether what Claude built is good, risky or fragile. It
  looks fine, and it usually is, until the day it isn't.
- You have no idea who can see an app, or where what people type into it
  ends up.
- You built something that an app you already pay for could have done.
- Every new app makes the pile a little bigger, and nobody can see the bill
  coming.

None of this is Claude's fault. Claude builds what it is asked to build.
What was missing was someone to ask the question nobody knew to ask, and to
give an opinion afterwards.

## What an engineer brings

Steadyship is an add-on for Claude that behaves like an engineer sitting in
the conversation with you. We built it to do the three things a good
engineer does for people who are not engineers.

**It asks what you don't know to ask.** When you ask for a change, it has
already read your business notes, your other apps and your spreadsheets. If
there is a question that would be expensive to get wrong, it asks it before
building. Should this attach to the whole job, or to each step inside it?
Where should this live so the rest of the team can see it? Isn't this
already kept in the price list on the shared drive? It suggests an answer,
you decide, and it builds. Usually that is one question. It is never a
questionnaire.

**It judges what you can't judge.** Ask it to review an app and the first
line is Yes, No or Not yet: can the team rely on this? Then it tells you
what would break, what data is at risk, and what would need to change. It
also answers the security questions most people don't think to ask: who can
see this, where what people type ends up, whether a password is sitting in
a file, whether the shared drive is open to anyone with the link. Every
claim says what it checked, and anything it couldn't verify is marked that
way rather than waved through. A second, independent reviewer checks the
first one's work. If you want the strongest check, that second review can
come from a model made by a different company, which won't share the blind
spots of the one that built the app.

**It brings engineering when it's needed, not before.** While an app is
one person's experiment, it is left alone. Once other people start relying
on it, Steadyship gives it the things software needs to be relied on: its
data in one shared, backed-up place that only one thing writes to; a home
that isn't someone's laptop; a check that it still works; a named owner;
and a record of why decisions were made. This happens step by step, with a
review at each step, rather than as a rebuild. Each addition comes with a
sentence on why it is worth having, and more if you ask.

## The path

Every app is at one of four stages, and Steadyship says which.

| Stage | What it looks like | Moves on when |
|---|---|---|
| Prototype | One file, one person's tool | someone else starts using it |
| Owned tool | Shared, backed-up data with one writer; a test; a named owner | two apps touch the same information |
| Proper app | A real framework, shared parts, data checked on the way in | the business depends on it daily |
| Platform | Several apps on one database, kept in step | they must stay consistent for the business to run |

Nobody in the business has to choose a framework, a database or a host.
When an app has reached the point where it should move on, Steadyship says
so, explains why, and offers to do it now or later. Either way the decision
is written down, and an app only moves up when the evidence says it should.

## Apps that stay in step

The pile of apps stops being a problem when they all read the same
information. Steadyship finds where the same price, job or customer has
been typed into two apps and a spreadsheet, shows where they already
disagree, and points every app at the one file that is the real master. A
shared glossary, which someone in the business owns, says what a "job" is,
how its number is written and what the stages are called, and new work is
checked against it.

## It checks the ground before anyone builds on it

Most of what goes wrong with home-made apps is not the code but the setup
around it: the shared drive that turns out to be read-only from one PC, or
the app that only ever worked on the laptop it was built on. So one prompt,
"Check this computer", runs three quick checks: can it reach GitHub from
here, can it read and write the shared drive your apps depend on, and can
it open one of your apps and tell you whether it works. Each ends in PASS,
FAIL or SKIP, and the answers are recorded. A FAIL at this point is good
news. It is the problem found in the first minute instead of the third
month.

## It stays out of the way

An engineer who slows everyone down gets ignored, so Steadyship keeps to a
few habits.

- **Short answers.** A reply fits on one screen: what it found, the three
  things that matter most, and what it would do first. Say "show me
  everything" or "more" for the rest. The full detail is always in the
  folder.
- **A sentence for anything it adds.** When it brings in a library, a test
  or a shared file, it says why in one sentence, and says more if you ask.
  We don't want anyone left thinking "it used to be faster, why is it
  doing all this now?"
- **No terminal, and no Git to learn.** The folder is a repository
  underneath, but nobody in the business has to know that. Steadyship
  commits from a state you have approved.
- **It doesn't get in the way of experiments.** While you are trying
  something out, build as you do today. It asks at most once, and only when
  the answer would be expensive to get wrong.

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
  you already pay for", it says so. We count that as it working.
- **Nothing leaks.** Any repository it creates is private, and it refuses
  to push to one that isn't. Passwords, secrets and large files are kept
  out of the folder. Whether business data may be processed in a cloud
  session is your call. It asks once and records the answer.

## What it is not

Steadyship doesn't host apps, it isn't a database, and it doesn't replace
Claude. It doesn't stop you prototyping, and it stays quiet until
something matters. It isn't a certificate that an app is secure. It tells
you what it checked and what it couldn't.

## Who it is for

Businesses where a few people who are not developers build their own tools
with Claude, and where those tools are starting to matter. We are building
it alongside a New Zealand boat builder whose staff did exactly that. One
person holds the accounts and does a one-off setup, the owner or a manager
decides what the business relies on, and everyone else keeps building.

## Getting started

About ten minutes: the [quick start](../README.md#quick-start) has a page
for each setup (Windows or Mac, Claude desktop or Claude Code) that walks
through installing the add-on and setting it up for your business.
