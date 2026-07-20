FROM node:18-alpine

WORKDIR /app

COPY package*.json ./

RUN npm install --only=production

COPY . .

# Enforce non-root execution
USER node

EXPOSE 3000

CMD ["node", "src/db/models.js"]
