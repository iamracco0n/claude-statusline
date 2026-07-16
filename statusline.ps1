#!/usr/bin/env pwsh
# Claude Code 상태줄 (Windows/PowerShell): 모델 · 5시간/주간 사용량(/usage) · 컨텍스트 사용률
# statusline.sh의 PowerShell 이식판. stdin으로 들어온 JSON을 파싱해 상태줄 한 줄을 출력한다.

$ErrorActionPreference = 'SilentlyContinue'
# ⟳ · 같은 유니코드가 깨지지 않도록 출력 인코딩 고정
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch {}

# stdin 전체 읽기
$raw = [Console]::In.ReadToEnd()
if ([string]::IsNullOrWhiteSpace($raw)) { return }

try {
    $d = $raw | ConvertFrom-Json
} catch {
    return
}

$e = [char]27
$RESET = "$e[0m"; $DIM = "$e[2m"; $BOLD = "$e[1m"

function Get-PctColor([object]$p) {
    if ($null -eq $p) { return $DIM }
    if ($p -ge 90) { return "$e[91m" }   # 빨강
    if ($p -ge 70) { return "$e[93m" }   # 노랑
    return "$e[92m"                       # 초록
}

# "a.b.c" 경로를 안전하게 따라가며 값을 꺼낸다 (없으면 $null)
function Get-Field([object]$obj, [string]$path) {
    $cur = $obj
    foreach ($k in $path.Split('.')) {
        if ($null -ne $cur -and ($cur.PSObject.Properties.Name -contains $k)) {
            $cur = $cur.$k
        } else {
            return $null
        }
    }
    return $cur
}

$parts = @()

$model = Get-Field $d 'model.display_name'
if (-not $model) { $model = Get-Field $d 'model.id' }
if (-not $model) { $model = '?' }
$parts += "$BOLD$model$RESET"

function Format-Limit([string]$label, [string]$base) {
    $p = Get-Field $d "$base.used_percentage"
    if ($null -eq $p) { return $null }
    $col = Get-PctColor $p
    $s = "$DIM$label$RESET $col$([math]::Round($p))%$RESET"
    $resets = Get-Field $d "$base.resets_at"
    if ($resets) {
        $now = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $mins = [int](($resets - $now) / 60)
        if ($mins -gt 0 -and $mins -lt 100000) {
            $h = [math]::Floor($mins / 60)
            $m = $mins % 60
            if ($h -gt 0) { $when = ("{0}h{1:D2}m" -f $h, $m) } else { $when = "${m}m" }
            $s += "$DIM(⟳$when)$RESET"
        }
    }
    return $s
}

$limits = @()
$l5 = Format-Limit '5h' 'rate_limits.five_hour'
$l7 = Format-Limit '7d' 'rate_limits.seven_day'
if ($l5) { $limits += $l5 }
if ($l7) { $limits += $l7 }
if ($limits.Count -gt 0) {
    $parts += ($limits -join '  ')
} else {
    $parts += "${DIM}usage: (첫 응답 후 표시)$RESET"
}

$ctx = Get-Field $d 'context_window.used_percentage'
if ($null -ne $ctx) {
    $parts += "${DIM}ctx$RESET $(Get-PctColor $ctx)$([math]::Round($ctx))%$RESET"
}

$sep = "$DIM · $RESET"
[Console]::Out.Write(($parts -join $sep))
