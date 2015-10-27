TheMightiestBlob = require('../lib/local_modules/the_mightiest_blob')
Player = require('../lib/local_modules/player')
MathExt = require('../lib/local_modules/math_ext')


WebSocketServer = require("ws").Server
clientize = require('./client')
_ = require('lodash')
lz4 = require('lzutf8')
md5 = require('js-md5')

random = (min, max, filter = ((n) -> n)) ->
  diff = max - min
  filter((Math.random() * diff) + min)

randomPosition = (game) ->
  new MathExt.Vector(
    random(0, game.configuration.worldSize, parseInt)
    random(0, game.configuration.worldSize, parseInt)
  )


module.exports = class
  constructor: (server) ->
    @game = new TheMightiestBlob(
      maxPlayers: 5
      worldSize: 500
    )
    @wss = new WebSocketServer {server: server}
    @lastGameState = null


  run: ->
    @wss.on "connection", (ws) =>
      clientize(@, ws)

    @game.on "game:state:change", (e) =>
      if @game.players.length > 0
        state = _.pick(@game, ['configuration', 'players'])
        @broadcastMessage("game:state:change", state)

  compressMessage: (message) ->
    lz4.compress message,
      outputEncoding: 'Base64'

  decompressMessage: (message) ->
    lz4.decompress message,
      inputEncoding: 'Base64'
      outputEncoding: 'String'

  decodeMessage: (message) ->
    JSON.parse @decompressMessage(message)

  composeMessage: (channel, data) ->
    channel: channel
    data: data

  broadcastMessage: (channel, data) ->
    composed = @composeMessage(channel, data)
    compressed = @compressMessage JSON.stringify(composed)

    disconnectIdx = new Array()
    _.each @wss.clients, (client, idx) =>
      if client.tmb.connected
        @_sendMessageTo(client, compressed)
      else
        console.log 'Client should be disconnected', idx, client.tmb

  sendMessage: (client, channel, data) ->
    composed = JSON.stringify @composeMessage(channel, data)
    compressed = @compressMessage composed
    console.log '<<< ', JSON.stringify(client.tmb), composed
    @_sendMessageTo(client, compressed)

  _sendMessageTo: (client, message) ->
    try
      client.send(message)
    catch e
      console.log '_sendMessageTo', e, client


  newPlayer: (socket, name) ->
    player = new Player(name)

    player.addBlob(
      randomPosition(@game),
      @game.configuration.startBlobMass
    )

    player.target = player.blobs[0].position

    @game.addPlayer player

    @sendMessage socket, 'join:success',
      uuid: player.uuid

    player

  removePlayer: (playerUuid) ->
    @game.removePlayer uuid: playerUuid

