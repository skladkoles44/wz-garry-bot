⚠️ ВНИМАНИЕ: Этот документ не содержит реальных секретов. Все значения (TOKEN, ADMIN_ID, DB_URL, WEBHOOK_SECRET) указаны как примеры. Реальные данные хранятся в файле .env, который не публикуется и не коммитится.

# 🧠 WZ Garry Bot — Полный технический паспорт

## 1. Общие сведения
**Название проекта:** `WZ Garry Bot`  
**Назначение:** Telegram-бот для WZ-систем (помощник/автоматизация).  
**Язык:** Node.js (v20.19.5)  
**Библиотека:** [Telegraf](https://telegraf.js.org/)  
**Менеджер процессов:** [PM2](https://pm2.keymetrics.io/)  
**Хранилище кода:** [GitHub — skladkoles44/wz-garry-bot](https://github.com/skladkoles44/wz-garry-bot)  
**Сервер:** VPS `89.111.171.170`, ОС Linux Ubuntu 22+  
**Путь проекта:** `/root/wz-garry-bot`  
**Запуск:** `pm2 start src/index.js --name wz-garry`

---

## 2. Структура проекта

/root/wz-garry-bot/ ├── src/                 # Исходный код (логика бота) │   └── index.js ├── deploy/              # Секреты, шифрованные файлы │   └── .env.prod.enc ├── docs/                # Документация безопасности │   └── security_plan_v1.5.7.md ├── stages/              # Этапы внедрения ├── scripts/             # Скрипты (инициализация, деплой) ├── package.json         # Node-пакеты и зависимости ├── .sops.yaml           # Конфигурация шифрования ├── .env                 # Расшифрованный .env (не коммитить!) └── README.md

---

## 3. Переменные окружения (.env)

TOKEN=<см. файл .env>

---

## 4. Основные команды разработки
```bash
npm init -y
npm i telegraf dotenv
npm i -D eslint jest husky
npx husky init


---

5. GitHub и CI/CD

Репозиторий: git@github.com:Skladkoles44/wz-garry-bot.git

Workflow: .github/workflows/ci.yml

Этапы: lint → test → build Docker → deploy SSH


Secrets в GitHub:

VPS_HOST

VPS_USER

SSH_KEY

SOPS_AGE_KEY




---

6. Деплой на VPS

git pull
npm ci
pm2 restart wz-garry
pm2 save


---

7. Автозапуск

pm2 startup
pm2 save
systemctl status pm2-root


---

8. PM2 управление

Действие	Команда

Проверить процессы	pm2 list
Логи	pm2 logs wz-garry --lines 30
Рестарт	pm2 restart wz-garry
Остановить	pm2 stop wz-garry
Автозапуск	pm2 save && pm2 startup



---

9. Telegram API диагностика

. ./.env
curl -s "https://api.telegram.org/bot${TOKEN}/getMe"
curl -s "https://api.telegram.org/bot${TOKEN}/getWebhookInfo"
curl -s "https://api.telegram.org/bot${TOKEN}/getUpdates"


---

10. Шифрование (SOPS / age)

Конфигурация .sops.yaml

creation_rules:
  - path_regex: deploy/\.env\.prod\.enc$
    age: ["age1p3zxpcu6jgc2gjht53xtmusx8kln4ptcqewzl3s25ur4cfw8nf0su3cr53"]

Ключи

Путь к приватному ключу: /root/.config/sops/age/keys.txt

Формат:

# created: 2024-10-30
# public key: age1p3zxpc...
AGE-SECRET-KEY-1YFZ...


Расшифровка

export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops -d deploy/.env.prod.enc > .env

Шифрование

sops -e --age "age1p3zxpc..." .env > deploy/.env.prod.enc


---

11. Ключи и безопасность

Тип	Расположение	Защита

age private	/root/.config/sops/age/keys.txt	chmod 600
.env	/root/wz-garry-bot/.env	chmod 600
pm2 logs	/root/.pm2/logs/	—
systemd unit	/etc/systemd/system/pm2-root.service	root



---

12. GPG (альтернатива age)

gpg --full-generate-key
gpg --armor --export KEY_ID > public.gpg
sops -e --pgp KEY_ID .env > deploy/.env.prod.enc


---

13. Ротация ключей

1. Сгенерировать новый ключ.


2. Добавить public в .sops.yaml.


3. Расшифровать и перешифровать файлы.


4. Удалить старый ключ из .sops.yaml.


5. Удалить приватный ключ со старых машин.




---

14. CI/CD с шифрованием

- name: Decrypt secrets
  run: |
    echo "${{ secrets.SOPS_AGE_KEY }}" > ~/.config/sops/age/keys.txt
    sops -d deploy/.env.prod.enc > .env


---

15. Мониторинг

Логи: pm2 logs wz-garry

Uptime: pm2 describe wz-garry | grep uptime

Загрузка: pm2 monit



---

16. Вебхуки (альтернатива polling)

await bot.telegram.setWebhook('https://bot.example.com/telegraf/SECRET');
bot.startWebhook('/telegraf/SECRET', null, 3000);


---

17. Nginx + SSL

/etc/nginx/sites-available/wz-garry-bot.conf

server {
  listen 443 ssl;
  server_name bot.example.com;
  ssl_certificate /etc/letsencrypt/live/bot.example.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/bot.example.com/privkey.pem;

  location /telegraf/ {
    proxy_pass http://127.0.0.1:3000/telegraf/;
  }
}


---

18. Команды бота

Команда	Назначение

/start	Приветствие
/ping	Проверка связи
/help	Справка



---

19. Уведомления администратору

const ADMIN_ID = process.env.ADMIN_ID;
const notify = (t) => bot.telegram.sendMessage(ADMIN_ID, t);
notify('🚀 Bot started');


---

20. План обслуживания

Еженедельный рестарт: crontab -e

0 4 * * 1 pm2 restart wz-garry

Проверка зависимостей: npm outdated, npm audit fix

Бэкап ключей: /root/.config/sops/age/keys.txt (офлайн копия)



---

21. Контрольные точки

Элемент	Путь

Проект	/root/wz-garry-bot
Логи	/root/.pm2/logs/
Ключи	/root/.config/sops/age/keys.txt
.env	/root/wz-garry-bot/.env
systemd	/etc/systemd/system/pm2-root.service



---

22. Краткая инструкция администратора

pm2 status
pm2 logs wz-garry --lines 50
cd /root/wz-garry-bot
git pull && npm ci && pm2 restart wz-garry
. ./.env && curl -s "https://api.telegram.org/bot${TOKEN}/getMe"
systemctl status pm2-root


---

23. Контроль безопасности

Root-доступ только по SSH-ключу.

.env и ключи шифрования доступны только root.

Секреты не коммитятся.

deploy/.env.prod.enc — единственный зашифрованный файл.

PM2 не логирует токены.



---

24. Скрипт обновления

#!/bin/bash
cd /root/wz-garry-bot
git pull
npm ci
pm2 restart wz-garry
pm2 save
echo "✅ Bot updated at $(date)"


---

25. Контроль версий и резервное копирование

Все изменения фиксируются в git.

Резервная копия .env и ключей хранится офлайн.

Возможна интеграция с GitHub Releases.



---

26. Методы шифрования

Метод	Используется	Особенности

age	✅	Современный, простой, быстрый
GPG	⚙️ (альтернатива)	Поддержка PGP-ключей
AWS KMS / GCP KMS	🏗️ (опционально)	Централизованное управление ключами
SOPS	✅	Обёртка над age/GPG/KMS для файлов



---

27. Управление ключами

Ключи создаются командой age-keygen -o ~/.config/sops/age/keys.txt

Публичные ключи хранятся в .sops.yaml

Приватные ключи — только на серверах

Ротация: добавить новый public → перешифровать → удалить старый

Резервные копии ключей — в офлайн-хранилище



---

28. Проверка шифрования

sops -d --list-keys deploy/.env.prod.enc


---

29. Ротация секретов

1. Новый ключ → добавить в .sops.yaml


2. Расшифровать .env.prod.enc


3. Перешифровать новым ключом


4. Проверить .env после дешифровки


5. Удалить старый ключ




---

30. Итоговая таблица инфраструктуры

Компонент	Путь	Назначение

Проект	/root/wz-garry-bot	Исходный код
Логи	/root/.pm2/logs/	Runtime-логи
Приватный ключ	/root/.config/sops/age/keys.txt	Расшифровка секретов
Unit-файл	/etc/systemd/system/pm2-root.service	Автозапуск
PM2 dump	/root/.pm2/dump.pm2	Список процессов
Шифрованный .env	deploy/.env.prod.enc	Хранение секретов
Расшифрованный .env	.env	Рабочие переменные



---

31. Контрольный чек-лист администратора

✅ Проверка работы бота
✅ Проверка токена Telegram
✅ Проверка ключей SOPS
✅ Автозапуск PM2 активен
✅ Backup ключей сохранён
✅ Зависимости обновлены (npm ci)
✅ Логи проверены (pm2 logs)


---

> Документ подготовлен: Мануал по эксплуатации WZ Garry Bot
Автор: @wheelrimzone
Дата: 2025-10-30
Формат: Markdown (.md)
Версия: 1.0 EOF

---

## 32. Политика коммитов и безопасность (Husky)
В проекте настроены git-хуки **Husky**:
- **pre-commit** блокирует попадание `.env`, `*.enc`, `keys.txt`, ищет сигнатуры токенов, запускает ESLint и (при наличии) тесты.
- **prepare-commit-msg** автоматически добавляет подпись:

Signed-off-by: jaCKdaniels 🥃 jaCKdaniels@AgeToPerfect.ion

Журнал работы хуков пишется в: `/root/wz-garry-bot/.husky.log`.

### Быстрый тест
```bash
git commit --allow-empty -m "test: hooks pipeline"


---

33. ESLint (flat config, v9+)

Конфигурация: eslint.config.js (flat).
Установленные пакеты:

eslint

@eslint/js

globals


Игноры: node_modules/**, .husky/**, deploy/*.enc.

Запуск:

npx eslint . --ext .js


---

34. Автоподпись коммитов (DCO-lite)

Хук prepare-commit-msg добавляет строку:

Signed-off-by: jaCKdaniels 🥃 <jaCKdaniels@AgeToPerfect.ion>

Цель — однозначная атрибуция автора и аудит изменений.


---

35. Логирование хуков

Файл: /root/wz-garry-bot/.husky.log
Содержит таймстемпы, автора коммита, результат ESLint/тестов и действия по подписи.

Просмотр последних записей:

tail -n 50 /root/wz-garry-bot/.husky.log


---

36. Напоминание о секретах

Не коммитить .env, *.enc, приватные ключи.

Секреты хранятся только локально или в SOPS-файлах, расшифровка — на доверенных машинах.

Примерные значения в документации — плейсхолдеры, реальные — только в .env.



---

## 32. Политика коммитов и безопасность (Husky)
В проекте настроены git-хуки **Husky**:
- **pre-commit** блокирует попадание `.env`, `*.enc`, `keys.txt`, ищет сигнатуры токенов, запускает ESLint и (при наличии) тесты.
- **prepare-commit-msg** автоматически добавляет подпись:

Signed-off-by: jaCKdaniels 🥃 jaCKdaniels@AgeToPerfect.ion

Журнал работы хуков пишется в: `/root/wz-garry-bot/.husky.log`.

### Быстрый тест
```bash
git commit --allow-empty -m "test: hooks pipeline"


---

33. ESLint (flat config, v9+)

Конфигурация: eslint.config.js (flat).
Установленные пакеты:

eslint

@eslint/js

globals


Игноры: node_modules/**, .husky/**, deploy/*.enc.

Запуск:

npx eslint . --ext .js


---

34. Автоподпись коммитов (DCO-lite)

Хук prepare-commit-msg добавляет строку:

Signed-off-by: jaCKdaniels 🥃 <jaCKdaniels@AgeToPerfect.ion>

Цель — однозначная атрибуция автора и аудит изменений.


---

35. Логирование хуков

Файл: /root/wz-garry-bot/.husky.log
Содержит таймстемпы, автора коммита, результат ESLint/тестов и действия по подписи.

Просмотр последних записей:

tail -n 50 /root/wz-garry-bot/.husky.log


---

36. Напоминание о секретах

Не коммитить .env, *.enc, приватные ключи.

Секреты хранятся только локально или в SOPS-файлах, расшифровка — на доверенных машинах.

Примерные значения в документации — плейсхолдеры, реальные — только в .env.



---

## 🧩 Security & Husky Workflow

Husky запускается автоматически перед каждым коммитом и выполняет несколько проверок:

1. **Блокировка секретов:**  
   Не позволяет закоммитить `.env`, `.enc` или `keys.txt`.

2. **Антиутечка токенов:**  
   Проверяет staged-файлы на наличие строк вроде `TOKEN=` или ключей формата `123456789:ABC...`.

3. **Линтер:**  
   Запускает `ESLint` для проверки синтаксиса JS-файлов.

4. **Тесты:**  
   Выполняет `npm test` (если они есть).

5. **Автоподпись:**  
   Автоматически добавляет строку:

Signed-off-by: jaCKdaniels 🥃 jaCKdaniels@AgeToPerfect.ion

🔒 Если найдены токены — коммит блокируется.  
✅ Если всё чисто — Husky пропускает коммит.

