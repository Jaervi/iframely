module.exports = {
  apps : [{
    name        : "iframely",
    script      : "server.js",
    instances   : process.env.MAX_WORKERS || 2,
    exec_mode   : "cluster",
    max_memory_restart: process.env.MAX_MEMORY || "120M",
    kill_timeout: 6000
  }]
}
