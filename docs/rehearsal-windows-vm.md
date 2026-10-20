# Windows rehearsal rig

How the Windows end-user tests are run without a Windows machine: a Windows 11
VM in Azure, driven from the Linux development box, with the Linux box's disk
mapped into the VM as a network drive. Built 20 Oct 2026; the first run's
findings are at the end.

## What exists

| Piece | Value |
|---|---|
| Azure subscription | "Azure subscription 1" (free trial, $200 / 30 days, then pay-as-you-go by choice) |
| Resource group | `steadyship-rehearsal`, Australia East |
| VM | `steadyship-win`, Windows 11 Pro 25H2, Standard D4s v5 (4 vCPU, 16 GB, nested virtualisation), Trusted launch |
| Admin user | `<admin user>` (password in the owner's password manager) |
| Auto-shutdown | 11:00 pm Auckland time, email warning first |
| Network | public RDP rule deleted; the VM is reachable only over Tailscale |
| Tailnet | Linux box `<linux tailnet ip>`, VM `<vm tailnet ip>` |
| Share | Linux `~/steadyship-share` exported by Samba as `\\<linux tailnet ip>\steadyship`, Tailscale addresses only; mapped in the VM as `Z:` |

Running cost at 10 hours a week is roughly $40 a month plus $20 for the disk.
Left running it is about $330 a month, which is what auto-shutdown prevents.

## One-time setup (already done; repeat only to rebuild)

1. **Azure.** Create the VM through the portal with the values above. Windows
   11 client images require ticking the multi-tenant hosting rights box, which
   needs a qualifying licence (Microsoft 365 Business Premium / E3 / E5 or
   Windows Enterprise). Without one, use Windows Server 2025 Datacenter.
2. **Linux box.** `sudo bash linux-share-setup.sh` (installs Tailscale and
   Samba, adds the `[steadyship]` share limited to `100.64.0.0/10`, sets a
   Samba password), then `sudo tailscale up`. The script lived in the session
   scratchpad; its share block is:

       [steadyship]
          path = /home/<user>/steadyship-share
          read only = no
          valid users = <user>
          hosts allow = 100.64.0.0/10 127.0.0.1
          hosts deny = ALL

3. **VM, from the portal's Run Command** (Operations, Run command,
   RunPowerShellScript, runs as SYSTEM, no login needed): download and install
   the Tailscale MSI from `pkgs.tailscale.com/stable/tailscale-setup-latest-amd64.msi`.
4. **VM, inside an RDP session as the admin user** (Tailscale on Windows
   follows the logged-in desktop user, so a login done as SYSTEM is dropped
   the moment someone signs in):

       & 'C:\Program Files\Tailscale\tailscale.exe' up --unattended
       net use Z: \\<linux tailnet ip>\steadyship /user:<linux user> /persistent:yes

   Then install Claude desktop from claude.ai/download in Edge and sign in.
5. **Close the public RDP port** (VM, Networking, Network settings, delete the
   `RDP` inbound rule) once RDP over `<vm tailnet ip>` is proven.

## Driving the VM from Linux

- RDP client: Remmina (`remmina -c steadyship-win.remmina`, profile with
  `resolution_mode=1`, `dynamic_resolution=1`, clipboard on). The RDP
  clipboard carries the Linux `CLIPBOARD` selection, so copy with
  Ctrl+Shift+C in a terminal, or `xclip -selection clipboard`.
- Automation without a human in the loop: `xwd` captures the Remmina window
  (convert with a few lines of PIL), `xdotool` types and clicks into it. A
  helper of that shape (`vm.sh shot|click|type|key`) is enough to run the
  whole README quick start in Claude desktop and read every reply from
  screenshots.
- Files inside the VM are read back with Run Command (`Get-Content`); git
  there refuses SYSTEM for "dubious ownership", which is fine, read the files
  instead.
- Anything that needs a password or a sign-in (Samba mapping, Tailscale
  login, Claude sign-in, GitHub) is the owner's step over RDP.

## Running the rehearsal

Install the plugin (it syncs across devices on the account, so it may already
be there), create an empty folder such as `C:\Users\<admin user>\steadyship-test`,
choose it in a new session, and say, one at a time:

1. Try Steadyship with the demo business
2. Run steadyship status
3. run spike 0
4. run spike b
5. run spike b again, but against the Z: drive
6. run spike c, the app is job-board
7. What apps do we have and where is the same information kept twice?

Account note: this rig runs on the owner's Max account. The design partner is
on a Team plan, where plugin installs can be restricted by the org admin, so
spike e stays a question for them.

## Findings, first run (20 Oct 2026, plugin 0.4.2)

- **Claude desktop on Windows, "This computer" mode, is native Claude Code**
  with Windows paths and Git Bash. There is no Linux sandbox and no
  `/sessions/<id>/mnt` folder, unlike the Mac run. Everything the Mac learned
  about attached-folder paths does not apply here.
- **A fresh Windows machine has no git and no bash.** The demo skill stopped
  before creating anything, said so, and offered a winget install of Git for
  Windows. `winget` was not on PATH for the shell; the skill found it under
  the App Installer folder. Fixed in the skills: they now check `uname -s`
  and know the winget fallback.
- **init.sh rejected `C:\Users\...`** and the skill retried with `/c/Users/...`.
  Fixed: under Git Bash the script now translates Windows paths with `cygpath`.
- **Spike 0** PASS. All five sites reachable, including the Playwright CDN
  that the Mac sandbox blocked. Two false readings, both fixed: the gh
  download took the Linux build (now picks `windows_amd64.zip` and expands it
  with PowerShell), and `python3` reported ok because Windows ships a Store
  placeholder (now a tool must run `--version` successfully to count).
- **Spike b on the mapped Z: drive: PASS.** Both Claude's file tools and the
  bash script read, wrote and deleted on `\\<linux tailnet ip>\steadyship`, seen
  as `/z/` from bash, and the Linux box showed the folder's timestamp change
  with nothing left behind. The runbook's warning that scripts cannot see
  mapped drives did not apply.
- **Spike c: PASS** after the skill stopped for the missing Node, offered a
  winget install of Node.js LTS, and reran. Node 24 and the test browser went
  in under a minute and job-board opened with no errors. One fix: the smoke
  script looked for the browser only in the Linux and Mac cache folders, so
  Windows would have re-downloaded it every run; it now also checks
  `%LOCALAPPDATA%\ms-playwright`.
- **The assessment question** ran the assess skill: it read all six apps,
  the business notes and the spreadsheets, wrote `docs/assessment/` (SUMMARY
  plus one file per app) and answered with the duplicated code (money and
  date helpers, a drifted rounding copy, header colours and fonts), seven
  risks led by under-quoting from stale prices and browser-only storage, and
  three first moves (Quote Builder reads the price list, Jobs.csv becomes the
  single job list, agree the spelling rules). Same shape as the Mac result.
- **Every step of the README quick start passed on Windows** with plugin
  0.4.2, with the skill recovering twice (Git, Node) on a bare machine.
- **Installing the plugin itself needs git.** After the repo went public a
  fresh install on the VM failed with "git is required to install the
  plugin", even though the skill had installed Git earlier in the session:
  Claude desktop had started before Git existed and kept its old PATH. So
  on a bare Windows machine the order is Git for Windows first, restart
  Claude desktop, then add the marketplace. The README quick start now says
  so; the skills' own winget fallback only matters for Node.
- **Second run, plugin 0.4.6 (same day).** The demo built first time with
  no path retry (the `cygpath` fix), and the skill now checks shell, git and
  the plugin files before asking anything.
- **Getting 0.4.6 onto the VM needed "Upload plugin".** The account-level
  "steadyship" marketplace entry stayed pinned at 39bebf0 (0.4.2): Check for
  updates failed, Remove reported success but the entry survived a relaunch,
  and after it finally disappeared "Add marketplace" said "This marketplace is
  already added". That is a Claude desktop/claude.ai defect, reported. The
  upload path works: `scripts/package-plugin.sh` builds a zip of exactly the
  tracked plugin files (a hand-built zip had dropped `templates/.gitignore`
  and init refused to run, which is the template check doing its job), and
  the upload validator also rejects `<...>` in skill descriptions, fixed in
  0.4.6.
- **Spike c with Node uninstalled, plugin 0.4.6: PASS without a question.**
  The skill said "This computer doesn't have Node.js ... installing it now",
  installed it with winget, ran the check, and job-board opened clean. The
  only prompt left is the spike skill's deliberate "Shall I record that in
  RESULTS.md?".
- **Plugin updates**: "Check for updates" failed on a device without GitHub
  connected, so the VM ran 0.4.2 while 0.4.3 was published.

## Second VM, built from the CLI (20 Oct 2026)

The first VM was built in the portal. The second, `steadyship-win2`, was
built from this box with the Azure CLI (installed as a user tool:
`uv tool install azure-cli`, then `az login --use-device-code`, which the
owner approves in a browser). The free trial allows 4 cores per region and a
deallocated VM still holds them, so the second VM went to Australia
Southeast rather than deleting the first.

    az vm create -g steadyship-rehearsal -n steadyship-win2 \
      --image microsoftwindowsdesktop:windows-11:win11-25h2-pro:latest \
      --size Standard_D4s_v5 --location australiasoutheast \
      --security-type TrustedLaunch --enable-secure-boot true --enable-vtpm true \
      --license-type Windows_Client --admin-username steadyship --admin-password "$PW" \
      --public-ip-sku Standard --nsg-rule NONE --nsg steadyship-win2-nsg \
      --vnet-name steadyship-win2-vnet --subnet default
    az vm auto-shutdown -g steadyship-rehearsal -n steadyship-win2 \
      --location australiasoutheast --time 2300 --email "<owner email>"
    # then set the schedule's properties.timeZoneId to "New Zealand Standard Time" with az resource update

`$PW` is generated in the shell (`openssl rand -base64 21`, plus a symbol)
and never printed; the owner then sets a real password with the portal's
Reset password, so no credential passes through the session. `--nsg-rule
NONE` leaves no inbound rule: access is Tailscale only.

Tailscale goes on through Run Command (`az vm run-command invoke … --scripts
@file.ps1`): install the MSI, then `tailscale up --unattended`, which prints
a login link for the owner. **Expect to do the login twice.** The first,
from Run Command (SYSTEM), is dropped the moment the owner signs in to the
desktop; run `tailscale up --unattended` again from Run Command to get a
second link, approve it, and then run the same command once more from a
PowerShell window inside the desktop session, after which it sticks. Run
Command is also the way to look inside the VM without touching the desktop
(`git --version`, `Test-Path …`).

Findings so far on the fresh machine: `scripts/setup-windows.ps1`, pasted as
the README gives it, installed Git 2.55 and Node 24 and downloaded the
fallback zip with no questions asked. The CLI's error reporting hides the
real deployment error behind a traceback; `--debug` piped through
`grep '"message"'` shows it (here: `QuotaExceeded`).

## Third run: fresh machine, 20 Oct 2026, plugin 0.5.0 to 0.5.2

The quick start (`docs/quickstart/windows-claude-desktop.md`) on
`steadyship-win2` with nothing installed, the owner's Max account, apps
copied in from `Z:\demo-boatworks-apps` and spreadsheets on
`Z:\demo-boatworks-shared-drive`.

| Step | Result |
|---|---|
| Setup script | PASS first time: Git 2.55, Node 24, fallback zip, one "to do" (Claude desktop) |
| Claude desktop | Installed by the owner from claude.ai; it is now a Store (MSIX) app under `WindowsApps`, data in `%LOCALAPPDATA%\Claude`. Script detection fixed to match. |
| Add marketplace | "This marketplace is already added" on this account, the known sync defect; a new machine does not clear it. Upload plugin with the release zip worked, replacing the synced 0.4.6 with 0.5.0. |
| Set up Steadyship for Demo Boatworks | Ran the **demo** skill, because the name matches its triggers. Use a non-demo name for a real business; recorded as a finding, not changed. |
| Set up Steadyship for Harbour Boatworks | PASS: asked one question at a time, accepted all answers in one message, verified the shared drive, pointed at the next step. |
| Check this computer | All three PASS on first run, test browser installed by itself. `gh` did not install: Expand-Archive refuses a `.pkg` name. Fixed in 0.5.1. |
| What apps do we have… | Found the planted defects (UTC date, browser-only storage, stale prices, mismatched codes, "Demo Boatworks" titles), wrote `docs/assessment/`, and suggested `docs/context/business/` for notes, which the templates did not have. Added in 0.5.1. |
| Review the quote builder | Verdict with evidence and a second opinion from an independent reviewer on a different model; "I haven't changed anything." |
| Make the job board record hours | The ask step stopped before building, but Claude desktop rendered it as a two-button widget whose text said "as I recommend below" with nothing below: the person chose blind. Fixed in 0.5.2 (questions go inside the widget or the widget is not used). After "Yes": `Hours.csv` on the shared drive, Shop Timer writes, Job Board reads, decision recorded, two commits, nothing uploaded, limits stated plainly (Chrome or Edge only, folder picked once per browser). |

Other notes: Tailscale needed logging in twice (see the CLI section);
`net use Z:` succeeded without a prompt on the second try because Windows
had cached the credential from the first; Run Command cannot read `Z:`
(per-user mapping) or run `git` in the user's repository (dubious
ownership), so look at files by path instead.
