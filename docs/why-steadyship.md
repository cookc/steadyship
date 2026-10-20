# Why Steadyship

You have built something useful by talking to Claude. A job board, a quote
builder, a parts list. It works, people in the business use it, and it took
an afternoon instead of a quote from a software company.

Then it starts to matter. Someone relies on it. A second person builds
something that overlaps with it. A number in one app disagrees with the
spreadsheet. You ask Claude for one more change and something else stops
working. And nobody in the building can say whether the thing is actually
good enough to run the business on, or what it would take to make it so.

Steadyship exists for that moment.

## Does any of this sound familiar?

- The same information is typed into two apps and a spreadsheet, and they
  drift apart.
- An app keeps its data in the browser on one computer. If that machine
  goes, so does the data.
- Nobody owns an app. The person who built it has moved on, or forgot how
  it works.
- You cannot tell whether what Claude built is good, risky or fragile. It
  looks fine. It usually is fine, until it isn't.
- You built something that an app you already pay for could have done.
- Every new app makes the pile a little bigger, and nobody can see the bill
  coming.

None of this is a failing of Claude. Claude builds what it is asked to
build. The missing piece is the question nobody knew to ask, and the opinion
nobody was there to give.

## What Steadyship does

Steadyship is an add-on for Claude that behaves like an engineer sitting in
the conversation with you. It has three jobs.

**It asks before you build.** When you ask for a change, it looks at your
business notes, your other apps and your spreadsheets, then asks the one or
two questions that would be expensive to get wrong. Should this attach to the
whole job, or to each step inside it? Where should this live so the rest of
the team can see it? Isn't this already kept in the price list on the shared
drive? It recommends an answer, you decide, and it builds. Never a
questionnaire, never more than two questions.

**It tells you straight afterwards.** Ask it to review an app and it says, in
plain words, whether the team can rely on it: Yes, No, or Prototype. It names
what would break, what data is at risk, and what would need to change. The
verdict cites what it checked. Anything it could not verify is labelled as
such, never waved through.

**It writes things down and gives you a path.** What apps you have, what each
one is for, who relies on it, which spreadsheet is the real master for what,
and why each decision was made. From that it gives each app a route from
prototype to something the business can run on: data in a shared, backed-up
place with one owner; a home that isn't someone's laptop; a check that it
still works; a named owner. Step by step, with a review at each step, not a
rebuild.

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
  repository the business owns. Nothing is stored anywhere else.
- **It works without Steadyship.** Remove the add-on tomorrow and everything
  it wrote is still there and still useful. You are never worse off for
  having used it.
- **An honest answer.** If the right call is "don't build this, use the tool
  you already pay for", it says so. That is Steadyship working, not failing.
- **Nothing new leaves your computer.** It reads your apps and spreadsheets
  the same way Claude already does when you ask it to. It does not send them
  anywhere else.

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
