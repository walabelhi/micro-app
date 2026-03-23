# Dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy TS source code and tsconfig
COPY tsconfig.json ./
COPY src ./src

# Build TypeScript into dist/
RUN npm run build

# Default env (JWT_KEY passed at runtime)
ENV JWT_KEY=43ba2895a746d98f86a62d45f3fbfdd6

EXPOSE 3000

# Run safely: start app only if JWT_KEY is set
CMD ["sh", "-c", "if [ -z \"$JWT_KEY\" ] || [ \"$JWT_KEY\" = '43ba2895a746d98f86a62d45f3fbfdd6' ]; then echo 'JWT_KEY missing!'; exit 1; else node dist/index.js; fi"]
