# --- Stage 1: Base ---
FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
WORKDIR /app

# --- Stage 2: Dependencies ---
FROM base AS deps
COPY package.json pnpm-lock.yaml ./
# Install ALL dependencies (including devDeps for build)
RUN pnpm install --frozen-lockfile

# --- Stage 3: Build ---
FROM base AS build
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY . .
# Generate Prisma client
RUN pnpm prisma generate
# Build the application
RUN pnpm build
# Purge devDependencies for production
RUN pnpm prune --prod

# --- Stage 4: Production ---
FROM node:22-alpine AS production
LABEL maintainer="telegram-bot"

WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Copy built application and production dependencies
COPY --from=build /app/dist ./dist
COPY --from=build /app/node_modules ./node_modules
COPY --from=build /app/package.json ./package.json
COPY --from=build /app/prisma ./prisma

# Use a non-root user for security
RUN addgroup -S nodejs && adduser -S nestjs -G nodejs
RUN chown -R nestjs:nodejs /app
USER nestjs

# Expose the port (the user recently changed it to 8080 in main.ts)
EXPOSE 8080

# Start the application
CMD ["node", "dist/main"]
