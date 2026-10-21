# Trying Steadyship on your apps: what to expect

This is for you, before we sit down together. It says what Steadyship is,
what we'll do in the session, the few things I need from you beforehand,
and what it will and won't touch. Nothing here needs a technical background.

## What Steadyship is

You already build apps with Claude. Steadyship is an add-on for Claude that
behaves like an engineer sitting beside you while you do it:

- **While you're trying something out, it leaves you alone.** You build
  the way you do now. It adds one line at the end: when someone else is
  going to rely on this, tell me and I'll make it solid.
- **When you say "promote the cut planner"**, it does the engineering.
  It reads what you built, asks you a few questions about the business
  (never about code), then works through on its own: same results as
  before for the same inputs, the settings and prices in files on the
  drive instead of buried in the app, tests, a named owner, and a note of
  what it changed and why. Twenty minutes, most of it with you doing
  something else.
- **Two short conversations before the first promotion**: one about your
  data (which spreadsheet is the real master for what, who changes it,
  what must never be lost) and one about security (who should see what,
  where the files live, what happens when someone leaves). About ten
  minutes each. They're the two things that are hard to change later.
- **For an app people already rely on**, it asks the one or two questions
  an engineer would ask before a change: should this attach to the whole
  job or each step? Is this already in a spreadsheet somewhere? And it
  gives you a straight answer on whether an app is good enough for the
  team to rely on.
- **It writes things down**: what apps you have, what each one is for,
  which spreadsheet is the real master for what, and why each decision was
  made. So the next person (or you in six months) can see what's going on.

It runs inside Claude desktop on your own computer. Your apps stay in a
folder on your PC. Nothing goes anywhere it doesn't already go when you use
Claude today.

## What we'll do together

About an hour and a half, at your desk, you on the keyboard. I'll watch,
answer questions when you ask, and take notes. Three parts:

1. **Set it up on your apps (about 50 minutes).** You'll install Steadyship,
   set it up for the business, drop two of your apps in, let it check it can
   see your shared drive and run one app's tests, then get its assessment of
   the apps and a verdict on one of them. All with the apps you actually use.
2. **One real change, then a promotion (about 30 minutes).** You'll ask it
   for a change you've been meaning to make, in your own words, and watch
   it just build it. Then the two short conversations about your data and
   your security, and "promote" on the app you'd most like the team to
   use. This is the point of the day: we want to see whether its questions
   make sense to you and whether what comes back is something you'd hand
   to the workshop.
3. **Your verdict (about 20 minutes).** Five questions from me, your honest
   answers. "That was annoying" is as useful as "that was great".

If we run out of time, we stop; whatever didn't fit tells me something too.

## Before we meet

Ten minutes, whenever suits:

1. **Check Claude desktop.** Open it, click **Customize** in the left
   sidebar and see whether there is a **Plugins** tab. If there isn't, your
   Team admin needs to switch plugins on; tell me and I'll send you the exact
   thing to ask them.
2. **Tell me two things:** which version of Windows you're on (Settings,
   System, About), and where the shared spreadsheets live. A drive letter
   like `Z:`, or a SharePoint folder that shows up in File Explorer. Either
   is fine; I just need to know which.
3. **Pick two apps** you're happy to try this on, and **one change** you
   actually want made to one of them. Real is better than tidy.
4. **Name the decider.** Steadyship asks who in the business decides what
   everyone relies on. Usually the owner or a manager. Just a name.
5. **Make a copy of your apps folder** in File Explorer (right-click, Copy,
   Paste). We won't change the originals, but a copy costs nothing.
6. **Optional, saves five minutes on the day:** open PowerShell (press
   Start, type `PowerShell`, Enter), paste this line, press Enter, and say
   Yes if Windows asks. It installs a couple of standard tools Claude needs
   for plugins and tells you if anything else is needed.

   ```powershell
   irm https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup-windows.ps1 | iex
   ```

## On the day, in short

You'll type a handful of plain sentences into Claude, one at a time:

- "Set up Steadyship for [the business]"
- "Check this computer"
- "What apps do we have and where is the same information kept twice?"
- "Review the [one of your apps, by the name in that list]"
- The change you want, in your own words.
- "Set up my data", then "Set up my security"
- "Promote the [app]" 

"Check this computer" runs three one-minute checks, each answering one
question about your setup with a plain PASS, FAIL or SKIP: can it reach the
internet from here, can it read and write your shared drive, can it open one
of your apps and tell you whether it works. The answers get written down so
nobody has to wonder again. A FAIL is not a problem on the day; it's the
thing that would have bitten you three months in, found early.

When Steadyship asks you a question, answer it the way you'd answer a
colleague. If you don't know, say so; it will recommend something. The data
and security questions are about how the business works, not about
computers; there are no wrong answers, only ones it hasn't heard yet.

## What it will not do

- It will not change anything on your shared drive. One check writes and
  deletes a single temporary file to prove it can; it reads everything else.
- It will not put anything on GitHub (a place for keeping code) unless you
  say yes when it asks. We'll say no on the day.
- It will not touch your original apps; we work on the copies.
- It will not install anything beyond the standard tools above, and it will
  say so before it does.

## Afterwards

I'll write up what tripped you up and fix it, and we'll do a second, shorter
session once that's done. The aim is that your team can use this without me
in the room.

Chris
