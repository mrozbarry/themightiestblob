express = require('express')
path = require('path')
http = require('http')
app = express()
port = process.env.PORT || 5000
publicPath = path.resolve(__dirname, '..', 'public')
game = require('./modules/game.coffee')

app.use express.static(publicPath)

server = http.createServer(app)
server.listen(port)

