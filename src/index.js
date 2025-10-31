import 'dotenv/config';
import { Telegraf } from 'telegraf';

const bot = new Telegraf(process.env.BOT_TOKEN);
bot.start((ctx) => ctx.reply('Привет! Я WZ Garry 🚗'));
bot.help((ctx) => ctx.reply('Команды: /status, /help'));
bot.command('status', (ctx) => ctx.reply(`✅ ${new Date().toISOString()}`));

bot.launch();
console.log('Bot started');

process.once('SIGINT', () => bot.stop('SIGINT'));
process.once('SIGTERM', () => bot.stop('SIGTERM'));
