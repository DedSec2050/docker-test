# Use an official Node.js runtime as a parent image
FROM node:24-alpine3.21

# Install pnpm globally
RUN npm install -g pnpm

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and pnpm-lock.yaml files to leverage Docker cache for dependencies¯ß
COPY package.json pnpm-lock.yaml ./

# Install dependencies using pnpm
RUN pnpm install --no-frozen-lockfile


# Copy the rest of the application's code
COPY . .

# Expose the port your app runs on (update the port if necessary)
EXPOSE 3000

# Command to run your app
CMD ["pnpm", "run", "dev"]