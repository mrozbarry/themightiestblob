var express = require('express'),
    path = require('path'),
    http = require('http'),
    app = express(),
    port = process.env.PORT || 5000
    publicPath = path.resolve(__dirname, '..', 'public'),
    WebSocketServer = require("ws").Server

app.use(express.static(publicPath));

app.all('/w/*', function(req, res) {
  req.url = '/index.html'
  next()
});

var server = http.createServer(app)
server.listen(port)

console.log("http server listening on %d", port)

var wss = new WebSocketServer({server: server})
console.log("websocket server created")

wss.on("connection", function(ws) {
  var id = setInterval(function() {
    ws.send(JSON.stringify(new Date()), function() {  })
  }, 1000)

  console.log("websocket connection open")

  ws.on("close", function() {
    console.log("websocket connection close")
    clearInterval(id)
  })
})

