FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./

RUN npm ci --omit=dev

COPY src ./src

FROM node:20-alpine AS runtime
WORKDIR /app

COPY --from=builder /app /app

USER node

EXPOSE 3000

CMD ["node", "src/server.js"]
