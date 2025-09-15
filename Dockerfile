# Etapa de build
FROM node:18.18.0-bullseye-slim AS builder
WORKDIR /app

# Habilitar pnpm con Corepack
ARG PNPM_VERSION=9.4.0
RUN corepack enable && corepack prepare pnpm@${PNPM_VERSION} --activate

# Copiamos manifests primero (mejor cache). Si no tienes pnpm-lock.yaml, elimina esa línea.
COPY package.json pnpm-lock.yaml ./

# Copiamos el resto del código
COPY . .

# Instalar dependencias y construir
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# Etapa de runtime
FROM node:18.18.0-bullseye-slim AS runner
WORKDIR /app

# Copiamos lo necesario para ejecutar
COPY --from=builder /app/build ./build
COPY --from=builder /app/public ./public
COPY --from=builder /app/node_modules ./
