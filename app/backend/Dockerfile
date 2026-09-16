FROM node:22.23.2-alpine3.24

WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm \
    && rm -f /usr/local/bin/npm /usr/local/bin/npx \
    && addgroup -S farmdirect \
    && adduser -S farmdirect -G farmdirect

COPY --chown=farmdirect:farmdirect app.js server.js ./
COPY --chown=farmdirect:farmdirect config ./config
COPY --chown=farmdirect:farmdirect controllers ./controllers
COPY --chown=farmdirect:farmdirect middleware ./middleware
COPY --chown=farmdirect:farmdirect routes ./routes
COPY --chown=farmdirect:farmdirect services ./services
COPY --chown=farmdirect:farmdirect scripts ./scripts
COPY --chown=farmdirect:farmdirect migrations ./migrations

USER farmdirect

EXPOSE 5000

CMD ["node", "server.js"]