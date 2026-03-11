# Dockerfile for backend
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Compile TypeScript
RUN npm run build  

# Run the compiled JS
CMD ["node", "dist/index.js"]
