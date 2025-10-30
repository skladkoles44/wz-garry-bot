#!/bin/bash
set -Eeuo pipefail

# Обработка прерывания сразу
trap 'echo -e "${RED}❌ Скрипт прерван${NC}"; exit 1' INT TERM

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Repo and branches
REPO_DIR="${REPO_DIR:-$HOME/wz_garry_bot}"
STAGING_BRANCH="${STAGING_BRANCH:-local_snapshot_pending}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

# SSH / VPS
VPS_USER="${VPS_USER:-root}"
VPS_HOST="${VPS_HOST:-89.111.171.170}"
SSH_KEY="${SSH_KEY:-}"      # optional: path to private key
SSH_PORT="${SSH_PORT:-22}"  # optional: ssh port
SSH_BASE_OPTS="-C -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -o ConnectTimeout=30 -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new"

# Other
VPS_DIR="${VPS_DIR:-/opt/wz_garry_bot}"
PGPASS_FILE="${PGPASS_FILE:-$HOME/.pgpass}"
BACKUP_SH="${BACKUP_SH:-$REPO_DIR/backup.sh}"

# Build ssh command array
build_ssh_cmd() {
  local target="${VPS_USER}@${VPS_HOST}"
  local -a cmd=(ssh)
  [[ -n "${SSH_PORT}" && "${SSH_PORT}" != "22" ]] && cmd+=(-p "${SSH_PORT}")
  [[ -n "${SSH_KEY}" && -f "${SSH_KEY}" ]] && cmd+=(-i "${SSH_KEY}")
  read -r -a opts <<< "${SSH_BASE_OPTS}"
  cmd+=("${opts[@]}" "${target}")
  printf '%s\0' "${cmd[@]}"
}

main() {
  echo -e "${GREEN}📂 1. Локальный коммит и пуш staging${NC}"
  [[ ! -d "$REPO_DIR" ]] && { echo -e "${RED}❌ Репозиторий $REPO_DIR не найден${NC}"; exit 1; }
  cd "$REPO_DIR"

  [[ -n "$(git status --porcelain)" ]] && git add src/bot.js db/schema.sql docker-compose.yml .env.example .gitignore
  if git diff --staged --quiet; then
    echo -e "${YELLOW}Нет изменений для коммита${NC}"
  else
    git commit -m "Add/update bot.js, schema, compose" || echo -e "${YELLOW}Commit skipped${NC}"
  fi
  git push origin "$STAGING_BRANCH" || echo -e "${YELLOW}⚠️ Push staging failed${NC}"

  echo -e "${GREEN}🔀 2. Merge staging → main${NC}"
  git fetch origin "$STAGING_BRANCH" || true
  git checkout "$MAIN_BRANCH"
  git merge-base --is-ancestor "$STAGING_BRANCH" "$MAIN_BRANCH" && echo -e "${YELLOW}Staging уже в main${NC}" || git merge --no-ff --no-edit "$STAGING_BRANCH"
  git push origin "$MAIN_BRANCH" || echo -e "${YELLOW}⚠️ Push main failed${NC}"

  echo -e "${GREEN}🖥️ 3–4. VPS deploy (pull + build + run)${NC}"
  IFS= read -r -d '' -a SSH_CMD_ARRAY < <(build_ssh_cmd) || true
  [[ ${#SSH_CMD_ARRAY[@]} -eq 0 ]] && { echo -e "${RED}❌ SSH command empty${NC}"; exit 1; }
  "${SSH_CMD_ARRAY[@]}" echo "Connection test" >/dev/null 2>&1 || { echo -e "${RED}❌ VPS not reachable${NC}"; exit 2; }

  "${SSH_CMD_ARRAY[@]}" bash -s <<EOF
set -euo pipefail
cd "$VPS_DIR" || { echo "❌ Remote: $VPS_DIR not found"; exit 1; }
DC_CMD='docker-compose'
command -v docker compose >/dev/null 2>&1 && DC_CMD='docker compose'
git fetch origin --quiet
git checkout "$MAIN_BRANCH"
git reset --hard "origin/$MAIN_BRANCH"
ls -la src/bot.js db/schema.sql docker-compose.yml 2>/dev/null || echo "⚠️ Some files missing"
command -v npm >/dev/null 2>&1 && [[ -f package.json ]] && npm ci --only=production || npm install --omit=dev || true
\$DC_CMD down --remove-orphans || true
timeout 300 \$DC_CMD build --no-cache || { echo "❌ Build failed"; exit 1; }
\$DC_CMD up -d --force-recreate || { echo "❌ docker compose up failed"; exit 1; }
sleep 5
NAME=\$(docker ps --format '{{.Names}}' | grep -E 'wz_garry_bot|wz_bot|bot' | head -n1 || true)
[[ -n "\$NAME" ]] && docker logs --tail 10 "\$NAME" || echo "⚠️ Bot container not found"
curl -f --max-time 10 http://127.0.0.1:3000/healthz >/dev/null 2>&1 && echo "✅ Health OK" || echo "❌ Health fail"
curl -f --max-time 10 http://127.0.0.1:3000/readyz >/dev/null 2>&1 && echo "✅ Ready OK" || echo "❌ Ready fail"
EOF

  echo -e "${GREEN}💾 5. Dry-run backup check (local Termux)${NC}"
  export PGPASSFILE="$PGPASS_FILE"
  [[ -x "$BACKUP_SH" ]] && bash "$BACKUP_SH" --dry-run > "$REPO_DIR/test_backup.log" 2>&1 && echo -e "${GREEN}Dry-run complete, see $REPO_DIR/test_backup.log${NC}"
  echo -e "${GREEN}✅ Workflow complete${NC}"
}

main "$@"
