# syntax=docker/dockerfile:1

# ETAP 1: Budowanie
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .

# ETAP 2: Obraz produkcyjny
FROM node:20-alpine

# Zmienne środowiskowe
ENV NODE_ENV=production
ENV PORT=8080

# Metadane OCI
LABEL org.opencontainers.image.authors="Denys Khvyshchun" \
      org.opencontainers.image.title="Aplikacja Pogodowa - Lab8" \
      org.opencontainers.image.version="1.0"

WORKDIR /app

# Копіюємо все з першого етапу
COPY --from=builder /app ./

EXPOSE 8080

# Запуск
CMD ["node", "server.js"]
