# Backend service Dockerfile for payments
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Build TypeScript
RUN npm run build

EXPOSE 3000
CMD ["node", "dist/index.js"]
