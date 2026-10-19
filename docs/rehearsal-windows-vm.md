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
| Admin user | `steadyship` (password in the owner's password manager) |
| Auto-shutdown | 11:00 pm Auckland time, email warning first |
| Network | public RDP rule deleted; the VM is reachable only over Tailscale |
| Tailnet | Linux box `100.122.121.25`, VM `100.99.143.77` |
| Share | Linux `~/steadyship-share` exported by Samba as `\\100.122.121.25\steadyship`, Tailscale addresses only; mapped in the VM as `Z:` |

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
       net use Z: \\100.122.121.25\steadyship /user:<linux user> /persistent:yes

   Then install Claude desktop from claude.ai/download in Edge and sign in.
5. **Close the public RDP port** (VM, Networking, Network settings, delete the
   `RDP` inbound rule) once RDP over `100.99.143.77` is proven.

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
be there), create an empty folder such as `C:\Users\steadyship\steadyship-test`,
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
  bash script read, wrote and deleted on `\\100.122.121.25\steadyship`, seen
  as `/z/` from bash, and the Linux box showed the folder's timestamp change
  with nothing left behind. The runbook's warning that scripts cannot see
  mapped drives did not apply.
- **Spike c: PASS** after the skill stopped for the missing Node, offered a
  winget install of Node.js LTS, and reran. Node 24 and the test browser went
  in under a minute and job-board opened with no errors. One fix: the smoke
  script looked for the browser only in the Linux and Mac cache folders, so
  Windows would have re-downloaded it every run; it now also checks
  `%LOCALAPPDATA%\ms-playwright`.
- **Plugin updates**: "Check for updates" failed on a device without GitHub
  connected, so the VM ran 0.4.2 while 0.4.3 was published.
