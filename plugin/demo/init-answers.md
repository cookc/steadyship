# Demo Boatworks: answers to the setup questions

Read these aloud (or paste them) when `steadyship-init` asks.

1. **Business name:** Demo Boatworks.
2. **Who is setting this up (setup owner):** Sam Setup.
3. **Who is the sponsor:** Morgan Reid, the owner.
4. **GitHub owner and repository name:** owner `TBC` (no GitHub step for the demo), repository `demo-boatworks`.
5. **Where is the shared drive:** it depends on the machine.
   - Linux: `~/steadyship-demo-shared-drive`
   - Mac: `/Volumes/DemoBoatworks-Shared`
   - Windows: `Z:\Demo Boatworks`
6. **Where should the new repository folder go:** somewhere that is not on the
   shared drive and does not exist yet, for example `~/steadyship-demo`
   (Linux or Mac) or `C:\Users\<you>\steadyship-demo` (Windows; inside WSL
   give the Linux path).

After setup, the six apps in `apps/` go into the repo's `apps/` folder, the
three Markdown files in `business/` go into `docs/context/business/`, and the
files in `shared-drive/` go on the shared drive. `populate.sh` does this.
