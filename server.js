import * as sysUtils from './utils.js';
import app from './app.js';
import *  as https from 'https';

var host = process.env.HOST || CONFIG.host || '::';
// If it's 0.0.0.0, we prefer :: for better IPv6/IPv4 dual stack compatibility in Docker/Railway
if (host === '0.0.0.0') {
    host = '::';
}

var server = app.listen(process.env.PORT || CONFIG.port, host, function(){
    var addr = server.address();
    var bind = typeof addr === 'string' ? 'pipe ' + addr : 'port ' + addr.port;
    console.log('\niframely is running on ' + addr.address + ':' + addr.port);
    console.log('API endpoints: /oembed and /iframely; Debugger UI: /debug');
    console.log('Config: CACHE_TTL=' + CONFIG.CACHE_TTL + ', MAX_WORKERS=' + (process.env.MAX_WORKERS || 2) + ', MAX_MEMORY=' + (process.env.MAX_MEMORY || '120M') + ', HOST=' + host + '\n');
});

if (CONFIG.ssl) {
    https.createServer(CONFIG.ssl, app).listen(CONFIG.ssl.port);
}

console.log('');
console.log(' - support@iframely.com - if you need help');
console.log(' - twitter.com/iframely - news & updates');
console.log(' - github.com/itteco/iframely - star & contribute');

process.on('SIGTERM', () => {
    console.log('SIGTERM signal received: closing HTTP server');
    server.close(() => {
        console.log('HTTP server closed');
        process.exit(0);
    });
});