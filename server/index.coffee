
# ---

Webpack = require("webpack")
WebpackMiddleware = require("webpack-dev-middleware")
WebpackHotMiddleware = require("webpack-hot-middleware")
webpackConfig = require("../config/webpack.config.js")

# ---
#
http = require("http")
express = require("express")
path = require("path")


# ---

TheMightiestBlob = require('../lib/local_modules/the_mightiest_blob')
game = new TheMightiestBlob(maxPlayers: 5)
WebSocketServer = require("ws").Server

# ---

publicPath = path.resolve(__dirname, '..', 'public')

port = process.env.PORT || 5000

development = -> process.env.NODE_ENV != 'production'

app = express()

app.use express.static(publicPath)

if development()
  compiler = Webpack(webpackConfig)

  app.use WebpackMiddleware(compiler,
    publicPath: webpackConfig.output.publicPath
    contentBase: "assets/scripts"
    stats: {
      colors: true
      hash: false
      timings: true
      chunks: false
      chunkModules: false
      modules: false
    }
  )
  app.use WebpackHotMiddleware(compiler)


server = http.createServer(app)
server.listen port, ->
  console.log "http server listening on %d", port


wss = new WebSocketServer {server: server}
console.log "websocket server created"

wss.on "connection", (ws) ->
  ws.on "message", ->
  ws.on "close", ->

  ws.send
