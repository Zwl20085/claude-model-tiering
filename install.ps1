# Installs (or with -Uninstall removes) the model-tiering skill, rule and tier agents.
# Target: $env:CLAUDE_CONFIG_DIR if set and non-empty, else ~/.claude.
# Runs on Windows PowerShell 5.1 and PowerShell 7. Safe to re-run.
[CmdletBinding()]
param([switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path

if ($env:CLAUDE_CONFIG_DIR) { $config = $env:CLAUDE_CONFIG_DIR } else { $config = Join-Path $HOME '.claude' }

$skillSrc  = Join-Path $root 'skills\model-tiering'
$ruleSrc   = Join-Path $root 'rules\model-tiering.md'
$agentSrc  = Join-Path $root 'agents'
$skillsDir = Join-Path $config 'skills'
$skillDst  = Join-Path $skillsDir 'model-tiering'
$ruleDir   = Join-Path $config 'rules\common'
$ruleDst   = Join-Path $ruleDir 'model-tiering.md'
$agentDst  = Join-Path $config 'agents'

$agents = @(Get-ChildItem -LiteralPath $agentSrc -Filter 'tier-*.md' -File | Sort-Object Name)
if ($agents.Count -eq 0) { throw "No agents/tier-*.md found in $root" }

function Remove-IfPresent([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
        Write-Host "Removed      $Path"
    } else {
        Write-Host "Not present  $Path"
    }
}

Write-Host "Claude config dir: $config"

if ($Uninstall) {
    Remove-IfPresent $skillDst
    Remove-IfPresent $ruleDst
    foreach ($a in $agents) { Remove-IfPresent (Join-Path $agentDst $a.Name) }
    Write-Host 'Uninstalled. Other files under the config dir were left alone.'
    return
}

# Skill: replace the whole directory so files from an older install do not linger.
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null
if (Test-Path -LiteralPath $skillDst) { Remove-Item -LiteralPath $skillDst -Recurse -Force }
Copy-Item -LiteralPath $skillSrc -Destination $skillDst -Recurse
Write-Host "Installed    $skillDst"

New-Item -ItemType Directory -Force -Path $ruleDir | Out-Null
Copy-Item -LiteralPath $ruleSrc -Destination $ruleDst -Force
Write-Host "Installed    $ruleDst"

New-Item -ItemType Directory -Force -Path $agentDst | Out-Null
foreach ($a in $agents) {
    $dst = Join-Path $agentDst $a.Name
    Copy-Item -LiteralPath $a.FullName -Destination $dst -Force
    Write-Host "Installed    $dst"
}

Write-Host 'Start a new Claude Code session to pick up the rule, the skill (/model-tiering) and the agents.'
