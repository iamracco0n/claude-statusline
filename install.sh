#!/usr/bin/env bash
# Claude Code 사용량 상태줄 설치 스크립트
# statusline.sh를 ~/.claude/에 복사하고 settings.json에 statusLine을 등록한다.
set -euo pipefail

CLAUDE_DIR="${HOME}/.claude"
SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS="${CLAUDE_DIR}/settings.json"

mkdir -p "${CLAUDE_DIR}"

# 1) statusline.sh 복사
cp "${SRC_DIR}/statusline.sh" "${CLAUDE_DIR}/statusline.sh"
chmod +x "${CLAUDE_DIR}/statusline.sh"
echo "✓ ${CLAUDE_DIR}/statusline.sh 설치됨"

# 2) settings.json에 statusLine 등록 (기존 설정은 보존)
python3 - "$SETTINGS" <<'PY'
import json, os, sys

path = sys.argv[1]
try:
    with open(path) as f:
        cfg = json.load(f)
except FileNotFoundError:
    cfg = {}
except json.JSONDecodeError:
    print(f"! {path} 파싱 실패 — 수동으로 statusLine을 추가하세요.")
    raise SystemExit(1)

cfg["statusLine"] = {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 2,
    "refreshInterval": 5,
}

with open(path, "w") as f:
    json.dump(cfg, f, indent=2, ensure_ascii=False)
    f.write("\n")

print(f"✓ {path} 에 statusLine 등록됨")
PY

echo
echo "완료! Claude Code를 재시작하면 상태줄에 사용량이 표시됩니다."
