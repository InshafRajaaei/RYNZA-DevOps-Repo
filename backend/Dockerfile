# Use official Node.js image
FROM node:18-alpine

# Create app directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the code
COPY . .

# Expose backend port
EXPOSE 4000

# Start the app directly with node (no npm wrapper)
CMD ["node", "server.js"]