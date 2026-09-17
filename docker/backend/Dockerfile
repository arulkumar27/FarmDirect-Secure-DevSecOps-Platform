# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS dependencies

WORKDIR /app

COPY app/backend/package*.json ./

RUN npm ci --omit=dev


FROM node:22-bookworm-slim AS production

ENV NODE_ENV=production

WORKDIR /app

COPY --from=dependencies /app/node_modules ./node_modules
COPY app/backend/ ./

RUN chown -R node:node /app

USER node

EXPOSE 5000

CMD ["node", "server.js"]