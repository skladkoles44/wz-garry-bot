# WZ Garry Bot — безопасность и инфраструктура
Этот репозиторий содержит инфраструктурные файлы, план безопасности и этапы внедрения для Telegram-бота WZ Garry Bot (RU-only compliant).
## Состав репозитория
- `docs/` — утверждённые планы и политики (в т.ч. безопасность v1.5.7)
- `stages/` — этапы внедрения (инфра, безопасность, тесты, аудит, сопровождение)
- `scripts/` — служебные скрипты (инициализация окружения и т.п.)
- `db/`, `redis/`, `nginx/`, `lua/`, `src/` — каталоги под код/конфиги (будут заполняться по мере реализации)
## Быстрый старт
1. Создай `.env` (локально, не коммить): `cp .env.example .env` и заполни секреты.
2. Запусти инфраструктуру через Docker Compose.
3. Проверь `/health` и подключение бота.
## Полезное
- План безопасности: `docs/security_plan_v1.5.7.md`
- Чек-лист внедрения: `stages/01_infra_setup.md`

---

## 🔐 Коммиты и безопасность

**1. Husky-хуки (проверки перед коммитом):**
- Проверяют, чтобы не закоммитить `.env`, `.enc` и ключи.
- Ищут токены (`TOKEN_PLACEHOLDER=<пример>`).
- Запускают проверку кода через ESLint.
- Добавляют подпись автора.

**2. Автоматическая подпись**
Каждый коммит получает строку:

Signed-off-by: jaCKdaniels 🥃 jaCKdaniels@AgeToPerfect.ion

**3. Логи проверок**
Все действия хуков записываются в `/root/wz-garry-bot/.husky.log`.  
Чтобы посмотреть последние записи:
```bash
tail -n 20 /root/wz-garry-bot/.husky.log

4. Проверка кода ESLint используется для проверки синтаксиса JS.
Запустить вручную:

npx eslint . --ext .js

5. Безопасность

Не коммить .env и другие секреты.

Все реальные ключи хранятся только локально.

В репозиторий попадают только примерные значения.



---

## 🛡️ Техническая безопасность и автопроверки

### 🔐 Husky — защита коммитов
Husky запускается перед каждым `git commit` и выполняет несколько проверок:
- 🚫 Не допускает коммит `.env`, `.enc` и ключей (`keys.txt`)
- ⚠️ Ищет возможные токены (например `TOKEN=`) только в **не-Markdown файлах**
- 🧹 Проверяет код с помощью `ESLint`
- 🧪 Запускает тесты (если есть)
- ✍️ Добавляет подпись `Signed-off-by: jaCKdaniels 🥃 <jaCKdaniels@AgeToPerfect.ion>`

Если найдены токены — коммит блокируется.  
Если всё чисто — изменения проходят автоматически.

---

### 🧠 ESLint — проверка кода
ESLint следит за чистотой и корректностью синтаксиса JavaScript:
```bash
npx eslint . --ext .js

Ошибки нужно исправить перед коммитом, иначе Husky не пропустит изменения.


---

🧱 PM2 — процесс-менеджер

Бот работает через PM2:

pm2 status
pm2 logs wz-garry
pm2 restart wz-garry

PM2 автоматически перезапускает бота при сбое и запускает его после перезагрузки сервера.


---

🔒 Шифрование SOPS

Файл deploy/.env.prod.enc содержит зашифрованные переменные окружения.
Для расшифровки используется ключ:

/root/.config/sops/age/keys.txt

Команда расшифровки:

export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops -d deploy/.env.prod.enc > .env


---

✅ Итоговый Dev Flow

1. npm run lint        # Проверка кода
2. git add . && git commit -m "fix: ..."   # Husky запускает проверки
3. git push origin main                   # Отправка кода в GitHub
4. pm2 restart wz-garry                   # Перезапуск бота


---

## 🧩 CI/CD и автоматизация деплоя WZ Garry Bot

### 🚀 GitHub Actions (автодеплой на VPS)
После каждого коммита в ветку `main` запускается workflow `.github/workflows/deploy.yml`. Он делает полный деплой кода на VPS и перезапускает бота через PM2.

#### 🔐 Последовательность действий CI/CD (ядро workflow)
```yaml
- name: 🔐 Deploy via SSH
  uses: appleboy/ssh-action@v1.2.0
  with:
    host: \${{ secrets.VPS_HOST }}
    username: \${{ secrets.VPS_USER }}
    key: \${{ secrets.VPS_SSH_KEY }}
    script: |
      set -e
      cd /root/wz-garry-bot && \
      git fetch origin main && \
      git reset --hard origin/main && \
      pm2 describe wz-garry >/dev/null 2>&1 && \
      pm2 restart wz-garry || pm2 start src/index.js --name wz-garry && \
      pm2 save

📣 Telegram-уведомления

После успешного деплоя отправляется сообщение в Telegram (секреты TG_BOT_TOKEN, TG_CHAT_ID):

✅ WZ Garry Bot deployed to VPS

При ошибке приходит ❌-уведомление с просьбой посмотреть логи в Actions.


---

🧠 Логика деплоя

1. GitHub Actions подключается к VPS по SSH с приватным ключом (секрет VPS_SSH_KEY).


2. В каталоге /root/wz-garry-bot обновляется код: git fetch → git reset --hard origin/main.


3. Процесс PM2 wz-garry перезапускается (или стартует, если его не было).


4. Конфигурация PM2 сохраняется (pm2 save) для автоподъёма после рестарта сервера.




---

🔄 Ручной запуск деплоя из Termux

Запустить workflow без коммита:

gh workflow run "🚀 Deploy to VPS"

Посмотреть список последних прогонов:

gh run list --workflow="deploy.yml"

Показать логи последнего прогона:

gh run view $(gh run list --workflow="deploy.yml" --json databaseId --jq ".[0].databaseId") --log


---

💻 Мониторинг бота на VPS

Статус процесса:

ssh root@89.111.171.170 "pm2 status wz-garry"

Последние 30 строк логов:

ssh root@89.111.171.170 "pm2 logs wz-garry --lines 30 --timestamp"

Проверка токена бота (переменные уже подхватываются из .env на сервере):

ssh root@89.111.171.170 'cd /root/wz-garry-bot && . ./.env && curl -s "https://api.telegram.org/bot${TOKEN}/getMe"'


---

📱 Управление с Android (Termux)

Полный контроль CI/CD и логов — без входа на VPS.

Установка инструментов:

pkg update && pkg upgrade -y
pkg install git nodejs openssh gh -y

Авторизация в GitHub CLI:

gh auth login

Клонирование репозитория:

git clone git@github.com:Skladkoles44/wz-garry-bot.git ~/wz-garry-bot
cd ~/wz-garry-bot


---

🔧 Переменные и безопасность

.env не коммитится (препятствует Husky).

Секреты GitHub Actions:

VPS_HOST — адрес сервера

VPS_USER — SSH-пользователь

VPS_SSH_KEY — приватный ключ для деплоя

TG_BOT_TOKEN — токен Telegram-бота

TG_CHAT_ID — ID чата для уведомлений



> Примечание: в README намеренно нет строк вида TOKEN= и явных секретов — чтобы не триггерить защитные правила Husky.




---

## 🧩 CI/CD и автоматизация деплоя WZ Garry Bot

### 🚀 GitHub Actions (автодеплой на VPS)
После каждого коммита в ветку `main` запускается workflow `.github/workflows/deploy.yml`. Он делает полный деплой кода на VPS и перезапускает бота через PM2.

#### 🔐 Последовательность действий CI/CD (ядро workflow)
```yaml
- name: 🔐 Deploy via SSH
  uses: appleboy/ssh-action@v1.2.0
  with:
    host: \${{ secrets.VPS_HOST }}
    username: \${{ secrets.VPS_USER }}
    key: \${{ secrets.VPS_SSH_KEY }}
    script: |
      set -e
      cd /root/wz-garry-bot && \
      git fetch origin main && \
      git reset --hard origin/main && \
      pm2 describe wz-garry >/dev/null 2>&1 && \
      pm2 restart wz-garry || pm2 start src/index.js --name wz-garry && \
      pm2 save

📣 Telegram-уведомления

После успешного деплоя отправляется сообщение в Telegram (секреты TG_BOT_TOKEN, TG_CHAT_ID):

✅ WZ Garry Bot deployed to VPS

При ошибке приходит ❌-уведомление с просьбой посмотреть логи в Actions.


---

🧠 Логика деплоя

1. GitHub Actions подключается к VPS по SSH с приватным ключом (секрет VPS_SSH_KEY).


2. В каталоге /root/wz-garry-bot обновляется код: git fetch → git reset --hard origin/main.


3. Процесс PM2 wz-garry перезапускается (или стартует, если его не было).


4. Конфигурация PM2 сохраняется (pm2 save) для автоподъёма после рестарта сервера.




---

🔄 Ручной запуск деплоя из Termux

Запустить workflow без коммита:

gh workflow run "🚀 Deploy to VPS"

Посмотреть список последних прогонов:

gh run list --workflow="deploy.yml"

Показать логи последнего прогона:

gh run view $(gh run list --workflow="deploy.yml" --json databaseId --jq ".[0].databaseId") --log


---

💻 Мониторинг бота на VPS

Статус процесса:

ssh root@89.111.171.170 "pm2 status wz-garry"

Последние 30 строк логов:

ssh root@89.111.171.170 "pm2 logs wz-garry --lines 30 --timestamp"

Проверка токена бота (переменные уже подхватываются из .env на сервере):

ssh root@89.111.171.170 'cd /root/wz-garry-bot && . ./.env && curl -s "https://api.telegram.org/bot${TOKEN}/getMe"'


---

📱 Управление с Android (Termux)

Полный контроль CI/CD и логов — без входа на VPS.

Установка инструментов:

pkg update && pkg upgrade -y
pkg install git nodejs openssh gh -y

Авторизация в GitHub CLI:

gh auth login

Клонирование репозитория:

git clone git@github.com:Skladkoles44/wz-garry-bot.git ~/wz-garry-bot
cd ~/wz-garry-bot


---

🔧 Переменные и безопасность

.env не коммитится (препятствует Husky).

Секреты GitHub Actions:

VPS_HOST — адрес сервера

VPS_USER — SSH-пользователь

VPS_SSH_KEY — приватный ключ для деплоя

TG_BOT_TOKEN — токен Telegram-бота

TG_CHAT_ID — ID чата для уведомлений



> Примечание: в README намеренно нет строк вида TOKEN= и явных секретов — чтобы не триггерить защитные правила Husky.




---

## 🛡 Husky, ESLint и подписи коммитов

Этот репозиторий защищён pre-commit и prepare-commit-msg хуками. Они:
- блокируют попадание секретов и приватных ключей в git;
- запускают ESLint для базовой проверки синтаксиса JS;
- автоматически добавляют подпись `Signed-off-by` к коммиту.

### Что проверяет pre-commit

1) **Безопасность**
- Запрещает коммитить файлы вида `.env`, `.enc`, `keys.txt`.
- Ищет возможные токены в staged-диффе (паттерны для телеграм-ключей и т.п.).
  > Если нужно показать пример в документации — используйте **`TOKEN_PLACEHOLDER`** без знака `=`.

2) **Код-стайл**
- Запускает ESLint (flat config, v9).

3) **Тесты**
- Если тестов нет — хук не падает, только пишет, что тесты пропущены.

### Конфигурация ESLint (файл `eslint.config.js`)

```js
import js from "@eslint/js";
import globals from "globals";

export default [
  { ignores: ["node_modules/**", ".husky/**", "deploy/*.enc"] },
  js.configs.recommended,
  {
    files: ["**/*.js"],
    languageOptions: {
      ecmaVersion: 2022,
      sourceType: "module",
      globals: { ...globals.node } // даёт process, console и пр.
    },
    rules: {
      // добавляй правила по мере роста проекта
    }
  }
];

Запуск локально:

npx eslint . --ext .js

Хук pre-commit (обзор логики)

❌ Останавливает коммит, если в staged есть .env, .enc, keys.txt.

❌ Останавливает коммит при срабатывании регэкспов на токены.

✅ Запускает ESLint, при ошибках — останавливается.

ℹ️ Тесты: если нет, просто пишет, что пропущены.


Хук prepare-commit-msg

Автоматически дописывает в сообщение коммита строку вида:

Signed-off-by: jaCKdaniels 🥃 <jaCKdaniels@AgeToPerfect.ion>

Частые ситуации

Ложное срабатывание по слову TOKEN
Пиши в README так: TOKEN_PLACEHOLDER (без =).
Не вставляй реальное значение и не показывай примеры с форматом ключа.

Нужно закоммитить правку в README, а хук ругается
Проверь, нет ли в диффе строк, похожих на реальные секреты.
Используй нейтральные плейсхолдеры и вычищай примеры.

После клонирования не срабатывают хуки
Убедись, что dependencies установлены:

npm ci || npm i

Хуки уже в репозитории, дополнительные команды не нужны.

Обновление Husky
В проекте уже используется современный формат хуков (без старых строк запуска из v<10).
Если обновляешь Husky — сверяйся с их документацией, но перекладывать хуки не потребуется.


Ручной обход хуков (не рекомендуется)

На крайний случай:

git commit -m "msg" --no-verify

> Используй только для нетривиальных ситуаций (например, из-за нестабильных зависимостей на CI на чужой машине). В обычной работе — не нужно.




---

## 🧩 Структура проекта и назначение директорий

Репозиторий `wz-garry-bot` организован так, чтобы легко обновлять и сопровождать бота, CI/CD и инфраструктуру.

### 📂 Основные директории

| Путь | Назначение |
|------|-------------|
| **src/** | Исходный код бота. Основной файл — `index.js`, где инициализируется Telegraf и обрабатываются команды. |
| **deploy/** | Хранит зашифрованные `.env` и другие секреты (например, `.env.prod.enc`). Расшифровка выполняется только на сервере. |
| **docs/** | Документация и вспомогательные материалы. Здесь лежит `logo.png` и `security_plan_v1.5.7.md`. |
| **.husky/** | Git-хуки (`pre-commit`, `prepare-commit-msg`). Автоматически запускают проверки и защищают репозиторий от утечек. |
| **.github/workflows/** | Скрипты GitHub Actions. `deploy.yml` отвечает за CI/CD — подключается к серверу и перезапускает PM2. |
| **scripts/** | Пользовательские скрипты, например, для деплоя или миграций. |
| **stages/** | Рабочие этапы и промежуточные файлы разработки (опционально). |
| **node_modules/** | Автоматически создаётся npm при установке зависимостей. |
| **package.json / package-lock.json** | Метаданные проекта и список зависимостей. |
| **.env** | Конфигурация окружения (никогда не коммитится). |

### ⚙️ Ключевые компоненты

- **PM2** — менеджер процессов, обеспечивает автозапуск и стабильность бота.  
- **dotenv** — подгружает секреты из `.env`.  
- **Husky + ESLint** — автоматическая проверка кода перед коммитом.  
- **GitHub Actions (`appleboy/ssh-action`)** — деплой на VPS и уведомление в Telegram.  
- **Termux (Android)** — используется как мобильный DevOps-интерфейс для управления репозиторием, CI/CD и SSH-доступом.

---

## 🧠 Логика работы и взаимодействие

1. **Разработка** — правки делаются локально в Termux.  
2. **Коммит и пуш** — Husky проверяет код и подпись.  
3. **GitHub Actions** — запускает deploy workflow:  
   - Подключается по SSH к VPS.  
   - Выполняет `git pull`, `pm2 restart wz-garry`.  
   - Отправляет уведомление в Telegram.  
4. **PM2** — сохраняет и восстанавливает процессы после перезагрузки.  

> 💡 Все действия логируются в GitHub Actions и PM2, так что можно отследить полный цикл — от коммита до перезапуска бота.

