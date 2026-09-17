# syntax=docker/dockerfile:1

FROM node:22-bookworm-slim AS builder

WORKDIR /app

COPY app/frontend/package*.json ./

RUN npm ci

COPY app/frontend/ ./

RUN npm run build


FROM nginx:1.29-alpine AS production

COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]