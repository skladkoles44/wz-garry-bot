FROM node:20-alpine
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY src/ ./src/

# Используем правильную точку входа из package.json
CMD ["node", "src/bot.js"]
