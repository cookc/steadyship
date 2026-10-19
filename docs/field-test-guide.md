# Trying Steadyship on your apps: what to expect

This is for you, before we sit down together. It says what Steadyship is,
what we'll do in the session, the few things I need from you beforehand,
and what it will and won't touch. Nothing here needs a technical background.

## What Steadyship is

You already build apps with Claude. Steadyship is an add-on for Claude that
behaves like an engineer sitting beside you while you do it:

- **Before you build something**, it asks the one or two questions an
  engineer would ask and you probably wouldn't think to: where should this
  information live so other people can see it? Is this already kept in a
  spreadsheet somewhere? Should this attach to the whole job, or to each
  step inside it?
- **After something is built**, it gives you a straight answer on whether
  it is good enough for the team to rely on, and what would make it so.
- **It writes things down**: what apps you have, what each one is for,
  which spreadsheet is the real master for what, and why each decision was
  made. So the next person (or you in six months) can see what's going on.

It runs inside Claude desktop on your own computer. Your apps stay in a
folder on your PC. Nothing goes anywhere it doesn't already go when you use
Claude today.

## What we'll do together

About an hour and a half, at your desk, you on the keyboard. I'll watch,
answer questions when you ask, and take notes. Three parts:

1. **A pretend business (about 30 minutes).** Steadyship comes with a
   made-up boat builder called Demo Boatworks: six apps its staff "built with
   Claude" and the spreadsheets they run on. You'll install Steadyship and
   run through it on that first, so the first time you see it, nothing of
   yours is involved.
2. **Your real apps (about 40 minutes).** You'll set Steadyship up for the
   business, drop two of your apps in, let it check it can see your shared
   drive, get its assessment of the apps, and then ask it for a real change
   you've been meaning to make. That last bit is the point of the day: we
   want to see what it asks you before it builds, and whether that is useful.
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

- "Try Steadyship with the demo business"
- "Run steadyship status", "run spike 0", "run spike b", "run spike c"
- "What apps do we have and where is the same information kept twice?"
- "Set up Steadyship for [the business]"
- "Review the [app]"
- And the change you want, in your own words.

A "spike" is just a short check of what your computer can actually do: reach
the internet, read the shared drive, run an app's tests. Each one ends with a
plain PASS, FAIL or SKIP. A FAIL is not a problem on the day; it's a finding.

When Steadyship asks you a question before building, answer it the way you'd
answer a colleague. If you don't know, say so; it will recommend something.

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
