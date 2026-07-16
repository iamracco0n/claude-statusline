#!/usr/bin/env pwsh
# Claude Code 사용량 상태줄 설치 (Windows/PowerShell)
# statusline.ps1을 ~/.claude/에 복사하고 settings.json에 statusLine을 등록한다.
$ErrorActionPreference = 'Stop'

$claudeDir = Join-Path $HOME '.claude'
$src       = Split-Path -Parent $MyInvocation.MyCommand.Path
$settings  = Join-Path $claudeDir 'settings.json'

New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null

# 1) statusline.ps1 복사
Copy-Item (Join-Path $src 'statusline.ps1') (Join-Path $claudeDir 'statusline.ps1') -Force
Write-Host "OK  $claudeDir\statusline.ps1 설치됨"

# 2) settings.json에 statusLine 등록 (기존 설정은 보존)
if (Test-Path $settings) {
    try {
        $cfg = Get-Content $settings -Raw -Encoding UTF8 | ConvertFrom-Json
    } catch {
        Write-Host "!  $settings 파싱 실패 — 수동으로 statusLine을 추가하세요." -ForegroundColor Yellow
        exit 1
    }
} else {
    $cfg = [PSCustomObject]@{}
}

$statusLine = [PSCustomObject]@{
    type            = 'command'
    command         = 'powershell -NoProfile -ExecutionPolicy Bypass -File "%USERPROFILE%\.claude\statusline.ps1"'
    padding         = 2
    refreshInterval = 5
}

if ($cfg.PSObject.Properties.Name -contains 'statusLine') {
    $cfg.statusLine = $statusLine
} else {
    $cfg | Add-Member -NotePropertyName statusLine -NotePropertyValue $statusLine
}

$cfg | ConvertTo-Json -Depth 20 | Set-Content $settings -Encoding UTF8
Write-Host "OK  $settings 에 statusLine 등록됨"

Write-Host ""
Write-Host "완료! Claude Code를 재시작하면 상태줄에 사용량이 표시됩니다."
