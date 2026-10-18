# Spike d — one app, hosted, behind sign-in, opened by someone else

**Question:** can one existing app be served from somewhere that isn't a
laptop, require a Microsoft sign-in, and be opened by a second staff member?

**Who:** {{SETUP_OWNER}} (setup, ~1 hour), then a second staff member. **Where:**
Azure portal + GitHub + any browser.

## Why Azure Static Web Apps (Free)

SharePoint will not serve HTML+JS (strict file handling). SWA Free costs
$0, deploys from the GitHub repo, and has built-in Microsoft sign-in with
"invitation" roles (up to 25 invited users on Free) — so only invited staff
can open it, without paying for the Standard tier. See the Steadyship proposal §6.

## Steps ({{SETUP_OWNER}})

1. Pick the app: the simplest one that passed spike c. Call it `<name>`.
2. Azure portal → Create → Static Web App: Plan **Free**; Source **GitHub**;
   repo `{{REPO_NAME}}`, branch `main`; Build preset **Custom**; app location
   `apps/<name>`; output location empty. Create. (Azure adds a workflow
   file and a repo secret `AZURE_STATIC_WEB_APPS_API_TOKEN_...`.)
3. Delete the Azure-generated workflow, copy
   `docs/spikes/hosting/azure-static-web-apps.yml` to
   `.github/workflows/deploy-spike-app.yml`, replace `SPIKE_APP` with
   `<name>` (two places) and the secret name with the one Azure created.
   Commit and push. Check the Actions run is green.
4. SWA → Role management → Invite: the second staff member's Microsoft
   account, provider **Microsoft Entra ID**, role **staff**, 24 hours.
   Send them the invite link.
5. Open the SWA URL yourself: you must be redirected to a Microsoft login,
   and after login see **403** (you aren't in `staff`) — that proves the
   gate works. Invite yourself too if you want in.

## Steps (second staff member)

Open the invite link, sign in with their work Microsoft account, then open
the app URL. The app should load.

## What Claude does

Nothing to run. This spike is done by {{SETUP_OWNER}} in the Azure portal and GitHub. If asked to run spike d, reply with the Pass criteria and the 'If it fails' options from this runbook, and ask which outcome occurred.

## Pass

Second staff member sees the app; an uninvited signed-in account gets 403;
a logged-out browser is redirected to login.
Paste: `| d | PASS | <date> | SWA Free, invited roles, url: <url> |`

## If it fails

- No Azure subscription available → **Fallback:** Cloudflare Pages +
  Cloudflare Access (free for up to 50 users, Entra as identity provider).
  Record `FAIL` + fallback. **Meaning:** hosting is still solved, with a
  second vendor to manage.
- Sign-in works but tenant restriction is wanted (any Microsoft account
  can *attempt* login) → invitations already restrict who gets in; strict
  tenant lock needs SWA Standard (~US$9/month). Note it; not a fail.
- Deploy action fails → check `app_location` matches the folder exactly
  (case-sensitive) and the secret name.
