# Backend service Dockerfile for expiration
# auth/Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy TypeScript config and source code explicitly
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript
RUN npm run build

EXPOSE 3000

# Run the compiled JS
CMD ["node", "dist/index.js"]
