# Telegram Bot - Setup and Running Guide

## 📋 Prerequisites

- Node.js 18+ and pnpm
- Docker and Docker Compose
- Telegram Bot Token (get from [@BotFather](https://t.me/botfather))

## 🚀 Quick Start

### 1. Clone and Install

```bash
cd telegram-bot
pnpm install
```

### 2. Configure Environment

Copy `.env.example` to `.env` and add your bot token:

```bash
cp .env.example .env
```

Edit `.env` and set:

```env
TELEGRAM_BOT_TOKEN=your_bot_token_here
```

### 3. Start Infrastructure

Start PostgreSQL, Redis, and MinIO:

```bash
docker-compose up -d
```

Verify services are running:

```bash
docker-compose ps
```

### 4. Run Database Migrations

```bash
pnpm prisma:migrate
```

This will create the database schema and generate Prisma client.

### 5. Start the Bot

Development mode (with hot reload):

```bash
pnpm start:dev
```

Production mode:

```bash
pnpm build
pnpm start:prod
```

## 🔧 Available Commands

### Bot Commands

- `/start` - Start new submission flow
- `/cancel` - Cancel current flow and clear data
- `/status` - Show current progress
- `/help` - Show help message

### NPM Scripts

```bash
# Development
pnpm start:dev          # Start with hot reload
pnpm start:debug        # Start with debugger

# Build
pnpm build              # Build for production
pnpm start:prod         # Run production build

# Database
pnpm prisma:generate    # Generate Prisma client
pnpm prisma:migrate     # Run migrations
pnpm prisma:studio      # Open Prisma Studio (DB GUI)

# Code Quality
pnpm lint               # Run ESLint
pnpm format             # Format code with Prettier
pnpm test               # Run tests
```

## 🗄️ Infrastructure Services

### PostgreSQL

- **Port**: 5432
- **Database**: telegram_bot
- **User**: postgres
- **Password**: postgres

### Redis

- **Port**: 6379
- **Database**: 0

### MinIO

- **API Port**: 9000
- **Console Port**: 9001 (Web UI)
- **Access Key**: minioadmin
- **Secret Key**: minioadmin
- **Bucket**: telegram-bot-uploads

Access MinIO Console: http://localhost:9001

## 📝 Environment Variables

| Variable             | Description                      | Default                                                      |
| -------------------- | -------------------------------- | ------------------------------------------------------------ |
| `TELEGRAM_BOT_TOKEN` | Your Telegram bot token          | Required                                                     |
| `DATABASE_URL`       | PostgreSQL connection string     | `postgresql://postgres:postgres@localhost:5432/telegram_bot` |
| `REDIS_HOST`         | Redis host                       | `localhost`                                                  |
| `REDIS_PORT`         | Redis port                       | `6379`                                                       |
| `MINIO_ENDPOINT`     | MinIO endpoint                   | `localhost`                                                  |
| `MINIO_PORT`         | MinIO port                       | `9000`                                                       |
| `MINIO_BUCKET`       | MinIO bucket name                | `telegram-bot-uploads`                                       |
| `ALLOW_TG_URLS`      | Allow Telegram URLs in URL field | `false`                                                      |
| `MAX_FILE_SIZE_MB`   | Maximum file size in MB          | `10`                                                         |
| `SESSION_TTL_HOURS`  | Session expiry in hours          | `24`                                                         |

## 🔍 Troubleshooting

### Bot doesn't respond

1. Check bot token is correct in `.env`
2. Verify bot is running: `pnpm start:dev`
3. Check logs for errors

### Database connection error

1. Ensure Docker services are running: `docker-compose ps`
2. Check DATABASE_URL in `.env`
3. Restart PostgreSQL: `docker-compose restart postgres`

### Redis connection error

1. Check Redis is running: `docker-compose ps`
2. Test connection: `docker-compose exec redis redis-cli ping`
3. Restart Redis: `docker-compose restart redis`

### File upload fails

1. Check MinIO is running: `docker-compose ps`
2. Access MinIO console: http://localhost:9001
3. Verify bucket exists
4. Check MinIO logs: `docker-compose logs minio`

## 🧪 Testing the Bot

1. Start the bot: `pnpm start:dev`
2. Open Telegram and find your bot
3. Send `/start`
4. Follow the prompts to submit data
5. Test validation by sending invalid data
6. Test language switching with `/lang kz`
7. Test editing fields from confirmation screen

## 🛑 Stopping Services

```bash
# Stop bot (Ctrl+C in terminal)

# Stop infrastructure
docker-compose down

# Stop and remove volumes (clears all data)
docker-compose down -v
```

## 📦 Project Structure

```
telegram-bot/
├── src/
│   ├── bot/                    # Bot module
│   │   ├── bot.module.ts
│   │   ├── bot.update.ts       # Main bot handlers
│   │   ├── constants/          # States and messages
│   │   └── services/           # Bot services
│   ├── database/               # Database module
│   │   ├── prisma.service.ts
│   │   └── repositories/
│   ├── storage/                # MinIO storage
│   │   └── minio.service.ts
│   ├── config/                 # Configuration
│   ├── app.module.ts
│   └── main.ts
├── prisma/
│   └── schema.prisma           # Database schema
├── docker-compose.yml          # Infrastructure setup
└── .env                        # Environment variables
```


## 🔒 Security Notes

- Never commit `.env` file
- Keep bot token secret
- File uploads are validated (type, size)
- Sessions expire after 24 hours (configurable)
- MinIO presigned URLs expire after 15 minutes
