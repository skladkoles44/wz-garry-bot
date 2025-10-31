# 🤖 WZ Garry Bot — Short Operator Guide

## ⚙️ Overview
- **Language:** Node.js 20  
- **Bot:** [Telegraf](https://telegraf.js.org/)  
- **Process manager:** PM2  
- **Server:** Ubuntu VPS `89.111.171.170`  
- **Repo:** [github.com/Skladkoles44/wz-garry-bot](https://github.com/Skladkoles44/wz-garry-bot)

---

## 🚀 Deployment
Автодеплой через **GitHub Actions**:
1. Любой push или ручной запуск workflow (`🚀 Deploy to VPS`).
2. GitHub подключается по SSH к серверу.
3. Выполняет:
   ```bash
   cd /root/wz-garry-bot
   git fetch origin main && git reset --hard origin/main
   pm2 restart wz-garry || pm2 start src/index.js --name wz-garry
   pm2 save

4. Telegram получает уведомление:
✅ WZ Garry Bot deployed to VPS.




---

🧰 Development (Termux)

Основные команды:

git pull          # Обновить код
git add .         # Добавить изменения
git commit -m "msg"
git push origin main
gh workflow run "🚀 Deploy to VPS"  # Ручной деплой
ssh root@89.111.171.170 "pm2 logs wz-garry --lines 20"


---

🧩 Structure

Папка / файл	Назначение

src/	Исходный код бота
docs/	Документация, логотип
deploy/	Шифрованные .env
.husky/	Git-хуки Husky
.github/workflows/	CI/CD pipeline
.env	Переменные окружения (не коммитить)



---

🛡️ Husky & ESLint

Перед каждым коммитом:

Проверка синтаксиса JS через ESLint

Защита от коммита .env, токенов и ключей

Автоподпись коммитов:

Signed-off-by: jaCKdaniels 🥃 <jaCKdaniels@AgeToPerfect.ion>



---

🧠 Summary

> Разработано для полной автоматизации:
Termux → GitHub → VPS → PM2 → Telegram.



