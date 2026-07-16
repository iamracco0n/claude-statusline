#!/usr/bin/env bash
# Claude Code 상태줄: 모델 · 5시간/주간 사용량(/usage) · 컨텍스트 사용률
INPUT=$(cat)
CC_JSON="$INPUT" python3 <<'PY'
import os, json, time

try:
    d = json.loads(os.environ.get('CC_JSON') or '{}')
except Exception:
    print("")
    raise SystemExit

def c(code): return f"\033[{code}m"
RESET = c(0); DIM = c(2); BOLD = c(1)
def pct_color(p):
    if p is None: return DIM
    if p >= 90: return c(91)   # 빨강
    if p >= 70: return c(93)   # 노랑
    return c(92)               # 초록

def get(path, default=None):
    cur = d
    for k in path.split('.'):
        if isinstance(cur, dict) and k in cur:
            cur = cur[k]
        else:
            return default
    return cur

parts = []

model = get('model.display_name') or get('model.id') or '?'
parts.append(f"{BOLD}{model}{RESET}")

def fmt_limit(label, base):
    p = get(f'{base}.used_percentage')
    if p is None:
        return None
    col = pct_color(p)
    s = f"{DIM}{label}{RESET} {col}{p:.0f}%{RESET}"
    resets = get(f'{base}.resets_at')
    if resets:
        mins = int((resets - time.time()) / 60)
        if 0 < mins < 100000:
            h, m = divmod(mins, 60)
            when = f"{h}h{m:02d}m" if h else f"{m}m"
            s += f"{DIM}(⟳{when}){RESET}"
    return s

limits = [x for x in (fmt_limit('5h', 'rate_limits.five_hour'),
                      fmt_limit('7d', 'rate_limits.seven_day')) if x]
if limits:
    parts.append("  ".join(limits))
else:
    parts.append(f"{DIM}usage: (첫 응답 후 표시){RESET}")

ctx = get('context_window.used_percentage')
if ctx is not None:
    parts.append(f"{DIM}ctx{RESET} {pct_color(ctx)}{ctx:.0f}%{RESET}")

print(f"{DIM} · {RESET}".join(parts))
PY
