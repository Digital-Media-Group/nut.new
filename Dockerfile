# Etapa de build
FROM node:18.18.0-bullseye-slim AS builder
WORKDIR /app

# Habilitar pnpm con la versión declarada en packageManager
ARG PNPM_VERSION=9.4.0
RUN corepack enable && corepack prepare pnpm@${PNPM_VERSION} --activate

# Copiamos manifests primero para cache
COPY package.json pnpm-lock.yaml ./

# Copiamos el resto del código
COPY . .

# Instalar dependencias y construir
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# Etapa de runtime
FROM node:18.18.0-bullseye-slim AS runner
WORKDIR /app

# Copiamos solo lo necesario desde el builder
COPY --from=builder /app/package.json ./
COPY --from=builder /app/pnpm-lock.yaml ./
COPY --from=builder /app/build ./build
COPY --from=builder /app/node_modules ./node_modules

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

# Arranque del servidor compilado de Remix
CMD ["node", "build/server/index.mjs"]
