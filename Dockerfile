# Etapa de build
FROM node:18.18.0-bullseye-slim AS builder
WORKDIR /app
# pnpm vía corepack
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate
# Copiamos manifests primero para aprovechar cache. Ajusta si no tienes lockfile.
COPY package.json pnpm-lock.yaml packageManager ./
# Copia del resto del código
COPY . .
# Instala deps y construye
RUN pnpm install --frozen-lockfile
RUN pnpm run build

# Etapa de runtime
FROM node:18.18.0-bullseye-slim AS runner
WORKDIR /app
# Copiamos artefactos construidos
COPY --from=builder /app ./
# Instala solo dependencias de producción (si tu runtime las necesita)
RUN corepack enable && corepack prepare pnpm@9.4.0 --activate && pnpm install --prod --frozen-lockfile
ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000
# Arranque del servidor compilado de Remix
CMD ["node", "build/server/index.mjs"]
