#!/bin/sh
echo "Starting PM2 with MAX_WORKERS=${MAX_WORKERS:-2} and MAX_MEMORY=${MAX_MEMORY:-120M} and CACHE_TTL=${CACHE_TTL:-86400} and HOST=${HOST:-::}"
exec npx pm2-runtime pm2.config.cjs
