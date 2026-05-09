# Backend API only (no frontend build).
FROM node:22-bookworm-slim AS build
WORKDIR /app/backend

COPY backend/package.json backend/package-lock.json ./
RUN npm ci --no-audit --no-fund

COPY backend/ ./
RUN npm run build \
  && npm prune --omit=dev

FROM node:22-bookworm-slim AS runner
WORKDIR /app/backend
ENV NODE_ENV=production

COPY --from=build /app/backend/package.json ./package.json
COPY --from=build /app/backend/package-lock.json ./package-lock.json
COPY --from=build /app/backend/node_modules ./node_modules
COPY --from=build /app/backend/dist ./dist

EXPOSE 3001
USER node

CMD ["node", "--import", "./dist/instrument.js", "./dist/index.js"]
