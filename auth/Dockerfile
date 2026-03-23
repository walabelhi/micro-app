FROM node:20-alpine

WORKDIR /app

# Accept JWT_KEY as build argument
ARG JWT_KEY
ENV JWT_KEY=$JWT_KEY

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY tsconfig.json ./ 
COPY src ./src

# Build TypeScript
RUN npm run build

EXPOSE 3000

# Run the app normally
CMD ["node", "dist/index.js"]
