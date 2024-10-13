# Use Node.js latest base image
FROM node:latest

# Set working directory inside container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json from the app folder
COPY app/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application files from app folder
COPY app/ ./

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["npm", "start"]
