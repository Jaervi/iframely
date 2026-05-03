# Stage 1: Build dependencies
FROM node:22-alpine AS builder

WORKDIR /app

# Install build tools for potential native modules
RUN apk add --no-cache g++ make python3

# Copy package files for better layer caching
COPY package.json package-lock.json* ./

# Install only production dependencies
# Using 'npm ci' for more reliable and reproducible builds
RUN npm ci --production

# Stage 2: Final runtime image
FROM node:22-alpine

# Set default NODE_ENV to local as in the original
ENV NODE_ENV=local

WORKDIR /iframely

# Create non-root user for security
RUN addgroup --system iframelygroup && adduser --system iframely -G iframelygroup

# This will change the config to `config.<VALUE>.js` and the express server to change its behaviour.
# You should overwrite this on the CLI with `-e NODE_ENV=production`.
ENV NODE_ENV=local
ENV HOST=::
# Copy dependencies from the builder stage
COPY --from=builder /app/node_modules ./node_modules

# Copy the rest of the application code
COPY . .

# Ensure config.local.js exists and is writable by the non-root user
RUN touch config.local.js && chown iframely:iframelygroup config.local.js

# Switch to non-root user
USER iframely

# Expose the application port
EXPOSE 8061

# Use the existing entrypoint script
ENTRYPOINT [ "/iframely/docker/entrypoint.sh" ]
