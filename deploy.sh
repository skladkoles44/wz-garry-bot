#!/data/data/com.termux/files/usr/bin/bash
set -e

REPO="skladkoles44/wz-garry-bot"
MAX_RETRIES=3
RETRY_COUNT=0

check_github() {
  curl --ipv4 --silent --fail https://api.github.com/ > /dev/null
}

run_deploy() {
  echo "🔄 Запуск деплоя (Попытка $((RETRY_COUNT+1))/$MAX_RETRIES)..."
  gh workflow run -R "$REPO" .github/workflows/deploy.yml --ref main
}

# Проверяем связь перед началом
until check_github; do
  echo "❌ Нет связи с GitHub. Ожидание..."
  sleep 5
done

until run_deploy; do
  RETRY_COUNT=$((RETRY_COUNT+1))
  if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
    echo "❌ Не удалось запустить деплой после $MAX_RETRIES попыток. Проверь сеть."
    exit 1
  fi
  echo "⏸ Ошибка сети. Повтор через 10 сек..."
  sleep 10
done

echo "✅ Деплой запущен. Отслеживание статуса..."

RUN_ID=$(gh run list -R "$REPO" --workflow=deploy.yml \
  --json databaseId,createdAt,event \
  --jq 'map(select(.event=="workflow_dispatch")) | sort_by(.createdAt) | last.databaseId')

while :; do
  RESP=$(curl -sS -H "Authorization: token $GH_TOKEN" \
    "https://api.github.com/repos/$REPO/actions/runs/$RUN_ID")
  STATUS=$(jq -r '.status' <<<"$RESP")
  CONCL=$(jq -r '.conclusion // "-" ' <<<"$RESP")
  echo "📡 status=$STATUS | conclusion=$CONCL"
  [ "$STATUS" = "completed" ] && break
  sleep 15
done
