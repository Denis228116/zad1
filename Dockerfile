# syntax=docker/dockerfile:1

# ETAP 1: Budowanie (Builder)
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

# Kompletne Label'e w standardzie OCI 
LABEL org.opencontainers.image.authors="Denys Khvyshchun" \
      org.opencontainers.image.title="Aplikacja Pogodowa - Lab8" \
      org.opencontainers.image.description="Aplikacja webowa wyświetlająca aktualną pogodę z wttr.in" \
      org.opencontainers.image.version="1.0" \
      org.opencontainers.image.vendor="Politechnika Lubelska"

WORKDIR /app

# Kopiowanie plików z etapu builder z przypisaniem uprawnień dla użytkownika 'node'
COPY --chown=node:node --from=builder /app ./

USER node

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --spider http://localhost:8080/ || exit 1

EXPOSE 8080

CMD ["node", "server.js"]