const fs = require('fs')
const environments = require('./environments/environment')
const server = require('./config/server')
const routes = require('./config/routes')

if (!fs.existsSync('./tmp')) {
    fs.mkdirSync('./tmp')
}

server.set('port', environments.PORT)
server.use(routes)

process.on('uncaughtException', (err) => {
    console.log(' UNCAUGHT EXCEPTION ')
    console.log(`[Inside 'uncaughtException' event] ${err.stack}` || err.message)
})
server.listen(environments.PORT, environments.ipServer, () => {
    console.log(`Server up: ${environments.ipServer}:${server.get('port')}`)
})
