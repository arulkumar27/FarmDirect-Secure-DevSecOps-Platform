# Build React frontend
FROM node:22-alpine AS build

WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# Serve files using Nginx as a non-root user
FROM nginx@sha256:97d490c12ba55b4946b01546d1c3ed324e8d41ab1c9fcb2a616aa470620e5b46

# Give write access only to Nginx runtime locations.
# Change PID location because /run is root-owned.
RUN mkdir -p /var/cache/nginx /var/log/nginx \
    && chown -R nginx:nginx /var/cache/nginx /var/log/nginx \
    && sed -i 's#/run/nginx.pid#/tmp/nginx.pid#g' /etc/nginx/nginx.conf

COPY --from=build /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Frontend files and Nginx config stay read-only.
RUN chmod -R a-w /usr/share/nginx/html /etc/nginx/conf.d

USER nginx

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]