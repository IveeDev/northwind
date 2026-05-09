# --- Stage 1: build the API (TypeScript → JavaScript) ---
FROM node:22-bookworm-slim AS backend-build
WORKDIR /app
COPY . .
RUN npm install --no-audit --no-fund \
  && npm run build

# --- Stage 2: runtime image (only prod deps + built assets) ---
FROM node:22-bookworm-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

COPY package.json package-lock.json ./
RUN npm install --omit=dev --no-audit --no-fund && npm cache clean --force

COPY --from=backend-build /app/dist ./dist

EXPOSE 3001
USER node

CMD ["node", "dist/index.js"]