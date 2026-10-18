# Installs the model-tiering skill and always-on rule into ~/.claude (Windows PowerShell 5.1+).
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$claude = Join-Path $HOME '.claude'
$skillDst = Join-Path $claude 'skills\model-tiering'
$ruleDst  = Join-Path $claude 'rules\common'
New-Item -ItemType Directory -Force $skillDst | Out-Null
New-Item -ItemType Directory -Force $ruleDst  | Out-Null
Copy-Item (Join-Path $root 'skills\model-tiering\*') $skillDst -Force
Copy-Item (Join-Path $root 'rules\model-tiering.md') (Join-Path $ruleDst 'model-tiering.md') -Force
Write-Host "Installed skill  -> $skillDst"
Write-Host "Installed rule   -> $ruleDst\model-tiering.md"
Write-Host "Start a new Claude Code session; the rule loads automatically, the skill is /model-tiering."
