TheMightiestBlob = require('../lib/local_modules/the_mightiest_blob')
WebSocketServer = require("ws").Server
Client = require('./client')
_ = require('lodash')
lz4 = require('lzutf8')
md5 = require('js-md5')

module.exports = class
  constructor: (server) ->
    @game = new TheMightiestBlob(maxPlayers: 5)
    @wss = new WebSocketServer {server: server}
    @clients = new Array()
    @clientIdsToRemove = new Array()
    @clientCleanupTimeout = null

    console.log "websocket server created"

  run: ->
    @wss.on "connection", (ws) =>
      @clients.push (new Client(@, ws))

    @game.on "game:state:change", (e) =>
      state = _.pick(@game, ['configuration', 'players'])
      message = @encodeMessage("game:state:change", state)
      @broadcastMessage(message)

    # @game.on "game:players:change", =>
    #   @broadcastMessage "game:players:change", {}

  removeClientWithUuid: (uuid) ->
    clearTimeout(@clientCleanupTimeout) if @clientCleanupTimeout

    @clientIdsToRemove.push uuid

    @clientCleanupTimeout = setTimeout (=>
      _.each @clientIdsToRemove, (uuid) =>
        clientIndex = _.findIndex @clients, uuid: uuid
        client = @clients[clientIndex]
        @clients.splice(clientIndex, 1)
        client.destructor()
        client = null
      @clientIdsToRemove = new Array()
      @clientCleanupTimeout = null
    ), 1000

  compressMessage: (message) ->
    lz4.compress message, outputEncoding: 'Base64'

  decompressMessage: (message) ->
    lz4.decompress message,
      inputEncoding: 'Base64'
      outputEncoding: 'String'

  decodeMessage: (message) ->
    JSON.parse @decompressMessage(message)

  encodeMessage: (channel, data) ->
    @compressMessage JSON.stringify({
      channel: channel
      block: @lastOutgoing || undefined
      data: data
    })

  broadcastMessage: (message) ->
    @wss.clients.forEach (client) =>
      @sendMessageTo(client, message)

  sendMessageTo: (client, message) ->
    client.send(message)

