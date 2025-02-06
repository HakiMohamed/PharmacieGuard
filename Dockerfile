# Build stage
FROM node:18-alpine AS builder

WORKDIR /app

# Définir les arguments
ARG FIREBASE_PROJECT_ID
ARG FIREBASE_PRIVATE_KEY_ID
ARG FIREBASE_PRIVATE_KEY
ARG FIREBASE_CLIENT_EMAIL
ARG FIREBASE_CLIENT_ID
ARG FIREBASE_AUTH_URI
ARG FIREBASE_TOKEN_URI
ARG FIREBASE_AUTH_CERT_URL
ARG FIREBASE_CLIENT_CERT_URL
ARG FIRESTORE_DATABASE_URL
ARG JWT_SECRET
ARG MAIL_HOST
ARG MAIL_PORT
ARG MAIL_USER
ARG MAIL_PASS
ARG MAIL_FROM

# Copier les fichiers de dépendances
COPY package*.json ./
RUN npm install

# Copier le reste du code
COPY . .

# Créer le fichier .env avec les variables
RUN echo "FIREBASE_PROJECT_ID=${FIREBASE_PROJECT_ID}" > .env && \
    echo "FIREBASE_PRIVATE_KEY_ID=${FIREBASE_PRIVATE_KEY_ID}" >> .env && \
    echo "FIREBASE_PRIVATE_KEY=${FIREBASE_PRIVATE_KEY}" >> .env && \
    echo "FIREBASE_CLIENT_EMAIL=${FIREBASE_CLIENT_EMAIL}" >> .env && \
    echo "FIREBASE_CLIENT_ID=${FIREBASE_CLIENT_ID}" >> .env && \
    echo "FIREBASE_AUTH_URI=${FIREBASE_AUTH_URI}" >> .env && \
    echo "FIREBASE_TOKEN_URI=${FIREBASE_TOKEN_URI}" >> .env && \
    echo "FIREBASE_AUTH_CERT_URL=${FIREBASE_AUTH_CERT_URL}" >> .env && \
    echo "FIREBASE_CLIENT_CERT_URL=${FIREBASE_CLIENT_CERT_URL}" >> .env && \
    echo "FIRESTORE_DATABASE_URL=${FIRESTORE_DATABASE_URL}" >> .env && \
    echo "JWT_SECRET=${JWT_SECRET}" >> .env && \
    echo "MAIL_HOST=${MAIL_HOST}" >> .env && \
    echo "MAIL_PORT=${MAIL_PORT}" >> .env && \
    echo "MAIL_USER=${MAIL_USER}" >> .env && \
    echo "MAIL_PASS=${MAIL_PASS}" >> .env && \
    echo "MAIL_FROM=${MAIL_FROM}" >> .env

RUN npm run build

# Production stage
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install --only=production

COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.env ./.env
COPY src/mail/templates ./src/mail/templates

EXPOSE 3000

# Définir les variables d'environnement
ENV NODE_ENV=production
ENV PORT=3000

CMD ["node", "dist/main"]