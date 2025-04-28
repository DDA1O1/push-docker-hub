# Dockerfile

# Stage 1: Build the React application
FROM node:20-alpine as builder
WORKDIR /app

# Copy package.json and potentially package-lock.json (if it exists)
COPY package.json ./
# If you use package-lock.json, uncomment the next line
# COPY package-lock.json ./

# Install dependencies securely using npm ci (requires package-lock.json)
# If you don't have/use package-lock.json, use 'npm install' instead
RUN npm ci
# RUN npm install

# Copy the rest of the application source code
COPY . .

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with Nginx
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html

# Remove default Nginx static assets
RUN rm -rf ./*

# Copy built assets from the builder stage
COPY --from=builder /app/dist .

# Copy custom Nginx configuration (optional, but recommended for SPAs)
# We'll create this file next
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start Nginx when the container launches
CMD ["nginx", "-g", "daemon off;"]