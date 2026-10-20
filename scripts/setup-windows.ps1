# Steadyship: gets a Windows computer ready for the Steadyship plugin.
#
# What it does: installs Git for Windows and Node.js if they are missing (using
# winget, Windows' own installer), checks for Claude desktop, and downloads a
# copy of the plugin to your Downloads folder in case the normal install fails.
# It changes nothing else. It is safe to run more than once.
#
# Run it in PowerShell (Start, type PowerShell, Enter), by pasting:
#   irm https://raw.githubusercontent.com/cookc/steadyship/main/scripts/setup-windows.ps1 | iex
# or from a downloaded copy:
#   powershell -ExecutionPolicy Bypass -File setup-windows.ps1

$ErrorActionPreference = 'Continue'
$state = @{ todo = 0 }
function Ok($m)   { Write-Host "ok:    $m" -ForegroundColor Green }
function Note($m) { Write-Host "note:  $m" }
function Todo($m) { Write-Host "to do: $m" -ForegroundColor Yellow; $state.todo++ }
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
function Find-Tool($name) {
  $c = Get-Command $name -ErrorAction SilentlyContinue
  if ($c) { return $c.Source }
  return $null
}
function Tool-Version($cmd) {
  try { return (& $cmd --version 2>&1 | Select-Object -First 1) } catch { return '' }
}

Write-Host '== Steadyship setup for Windows =='
Write-Host "Windows $([Environment]::OSVersion.Version)"

# winget is how things get installed. It is normally on Windows 10/11 but not
# always on the PATH of a PowerShell window.
$winget = Find-Tool winget
if (-not $winget) {
  $p = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps\winget.exe'
  if (Test-Path $p) { $winget = $p }
}
if ($winget) { Ok "winget (the Windows installer) is available" }
else { Note "winget is not available, so nothing can be installed automatically" }

function Ensure-Tool($cmd, $id, $label, $url) {
  Refresh-Path
  if (Find-Tool $cmd) { Ok "$label is installed ($(Tool-Version $cmd))"; return }
  if (-not $winget) { Todo "install $label from $url"; return }
  Write-Host "Installing $label (about a minute). Say Yes if Windows asks for permission."
  & $winget install --id $id -e --accept-package-agreements --accept-source-agreements --disable-interactivity
  Refresh-Path
  if (Find-Tool $cmd) { Ok "$label installed ($(Tool-Version $cmd))" }
  else { Todo "$label did not install; install it from $url, then run this script again" }
}

$gitBefore = [bool](Find-Tool git)
Ensure-Tool git  Git.Git           'Git for Windows' 'https://git-scm.com/download/win'
Ensure-Tool node OpenJS.NodeJS.LTS 'Node.js'         'https://nodejs.org'

# Claude desktop: today a Store (MSIX) app that keeps its data in %LOCALAPPDATA%\Claude;
# older installs lived in %LOCALAPPDATA%\AnthropicClaude.
$claudeInstalled = $false
foreach ($d in @('Claude', 'AnthropicClaude')) { if (Test-Path (Join-Path $env:LOCALAPPDATA $d)) { $claudeInstalled = $true } }
try { if (Get-AppxPackage -Name '*Claude*' -ErrorAction SilentlyContinue) { $claudeInstalled = $true } } catch { }
if (Get-Process -Name Claude -ErrorAction SilentlyContinue) { $claudeInstalled = $true }
if ($claudeInstalled) { Ok 'Claude desktop is installed' }
else { Todo 'install Claude desktop from https://claude.ai/download (if it is already installed, ignore this)' }

if (-not $gitBefore -and (Find-Tool git)) {
  if (Get-Process -Name Claude -ErrorAction SilentlyContinue) {
    Todo 'Git was just installed: quit Claude desktop fully (right-click its icon by the clock, then Quit) and open it again, so it sees Git'
  } else {
    Note 'Git was just installed; Claude desktop will see it when you next open it'
  }
}

# A copy of the plugin, for the "Upload plugin" fallback.
$zip = Join-Path ([Environment]::GetFolderPath('UserProfile')) 'Downloads\steadyship-plugin.zip'
try {
  [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
  Invoke-WebRequest -UseBasicParsing -Uri 'https://github.com/cookc/steadyship/releases/latest/download/steadyship-plugin.zip' -OutFile $zip
  Ok "a copy of the plugin is at $zip (only needed if the normal install fails)"
} catch {
  Note "could not download a copy of the plugin ($($_.Exception.Message)); the normal install does not need it"
}

Write-Host ''
Write-Host '== Next, in Claude desktop =='
Write-Host '1. Customize (left sidebar) -> Plugins -> Add marketplace -> type cookc/steadyship -> Add.'
Write-Host '2. Find steadyship in the list -> Install.'
Write-Host "3. Only if that fails: Customize -> Plugins -> Add -> Upload plugin -> choose $zip"
Write-Host '4. Optional, for better reviews and tidier code: in the same Plugins list install feature-dev, code-review, pr-review-toolkit, security-guidance, frontend-design and code-simplifier (all by Anthropic). Steadyship works without them.'
Write-Host ''
if ($state.todo -eq 0) { Write-Host 'RESULT: READY' -ForegroundColor Green }
else { Write-Host "RESULT: $($state.todo) thing(s) to do, marked 'to do' above" -ForegroundColor Yellow }
