# Context

What Steadyship knows about this business that the code cannot say.
Steadyship reads every file here before it assesses, reviews, promotes or
finishes anything.

| File | What it holds | How it gets written |
|---|---|---|
| `business/` | how the work is organised, the glossary, who uses what, which file is the master for what | you, or "turn the files in <folder> into business notes" |
| `engineering.md` | facts the engineering standard cannot know (time zone, currency, browsers, platform); rows this business overrides | Steadyship asks each fact the first time it matters |
| `decisions.md` | every question Steadyship asked and the answer | Steadyship, as it goes |
| `data.md` | the owner's map of the business's information: each kind of thing, its master, who writes it, what must never be lost; and the rules apps follow | one conversation: say **set up my data** |
| `security.md` | who may see what, where files live, what would hurt if it left, backups, what happens when someone leaves; and the rules | one conversation: say **set up my security** |
| `shape.md` | the shape every app shares: parts, what is in `lib/`, how apps relate, what each app owns | the first promotion writes it; later ones keep to it |

The data and security conversations happen once, before the first app is
promoted, and are re-opened when the business outgrows them (a file past
its budget, two people writing at once, someone new, an app hosted). They
are the two things a business cannot cheaply retrofit, which is why they
come before the code.
