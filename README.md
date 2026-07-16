# claude-statusline

Claude Code 상태줄에 **사용량(rate limit)**과 **컨텍스트 사용률**을 띄워주는 스크립트.

별도 툴(ccusage 등) 없이 Claude Code 내장 `statusLine` 기능만 사용한다.
사용량 데이터는 Claude Code가 상태줄 command로 넘겨주는 JSON에서 뽑아온다.

## 표시 항목

```
Opus 4.8 · 5h 42%  7d 18%(⟳3h05m) · ctx 27%
```

- **모델명** — 현재 사용 중인 모델
- **5h** — 5시간 리밋 사용량
- **7d** — 주간 리밋 사용량, `(⟳남은시간)`은 리밋 리셋까지 남은 시간
- **ctx** — 컨텍스트 윈도우 사용률

퍼센트 색상: 90%↑ 빨강 / 70%↑ 노랑 / 그 이하 초록.

> 사용량(5h·7d)은 **첫 응답 이후**부터 표시된다. 세션을 막 시작했을 땐
> `usage: (첫 응답 후 표시)`로 뜬다.

같은 상태줄을 두 가지 셸로 구현해 뒀다. 기기에 맞는 쪽을 쓰면 된다.

| 플랫폼 | 스크립트 | 설치 |
|--------|----------|------|
| macOS / Linux (또는 Git Bash) | `statusline.sh` | `./install.sh` |
| Windows (PowerShell) | `statusline.ps1` | `install.ps1` |

## 설치 — macOS / Linux

```bash
git clone https://github.com/iamracco0n/claude-statusline.git
cd claude-statusline
./install.sh
```

`install.sh`가 하는 일:
1. `statusline.sh`를 `~/.claude/`로 복사
2. `~/.claude/settings.json`에 `statusLine` 블록 등록 (기존 설정은 보존)

설치 후 Claude Code를 재시작하면 상태줄에 사용량이 뜬다.

> WSL bash(`C:\WINDOWS\system32\bash.exe`)로 이 bash 버전을 돌리면 윈도우 경로·stdin
> 처리가 깨질 수 있다. **Windows 네이티브 Claude Code 앱에서는 아래 PowerShell 버전을 쓸 것.**

## 설치 — Windows (PowerShell)

git이 없다면 GitHub 웹에서 `statusline.ps1`을 받아 `%USERPROFILE%\.claude\`에 넣어도 된다.
git이 있으면:

```powershell
git clone https://github.com/iamracco0n/claude-statusline.git
cd claude-statusline
./install.ps1
```

`install.ps1`이 하는 일:
1. `statusline.ps1`을 `%USERPROFILE%\.claude\`로 복사
2. `settings.json`에 `statusLine` 등록 (기존 설정 보존, `powershell -File ...ps1`로 실행)

> 이미 동작하는 statusLine 설정이 있다면 굳이 덮어쓸 필요 없다.
> `command` 실행 방식은 환경마다 다를 수 있으니, 잘 돌던 설정이 있으면 그걸 유지하고
> `statusline.ps1` 파일만 교체하면 된다. 예시 설정은
> [`settings.windows.example.json`](settings.windows.example.json) 참고.

## 수동 설치

- **bash**: `statusline.sh`를 `~/.claude/`에 복사 → `settings.json`에
  [`settings.example.json`](settings.example.json)의 `statusLine` 블록 추가.
- **PowerShell**: `statusline.ps1`을 `%USERPROFILE%\.claude\`에 복사 → `settings.json`에
  [`settings.windows.example.json`](settings.windows.example.json)의 `statusLine` 블록 추가.

## 커스터마이즈

두 스크립트 모두 로직·출력 포맷이 동일하다. 해당 파일을 직접 수정하면 된다.
- 색상 임계값: `pct_color()` / `Get-PctColor` 의 `90`, `70`
- 표시 항목: `parts` 에 추가하는 부분
- 리밋 종류: `fmt_limit`/`Format-Limit`의 `rate_limits.five_hour` 등

## 제거

`~/.claude/settings.json`에서 `statusLine` 블록을 지우거나,
Claude Code에서 `/statusline` 명령으로 끈다.
