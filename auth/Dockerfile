# Dockerfile
FROM node:20-alpine

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript
RUN npm run build

# Default env (won’t be used since we pass it on run)
ENV JWT_KEY=43ba2895a746d98f86a62d45f3fbfdd6

EXPOSE 3000

# Safe start: check JWT_KEY first
CMD ["sh", "-c", "if [ -z \"$JWT_KEY\" ] || [ \"$JWT_KEY\" = '43ba2895a746d98f86a62d45f3fbfdd6' ]; then echo 'JWT_KEY missing!'; exit 1; else node dist/index.js; fi"]
