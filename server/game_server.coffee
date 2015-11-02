WebSocketServer = require("ws").Server
_ = require('lodash')
lz4 = require('lzutf8')

BlobPhysicsEngine = require('../lib/local_modules/blob_physics_engine')
clientize = require('./client')


module.exports = class
  constructor: (server) ->
    @wss = new WebSocketServer {
      server: server
      clientTracking: true
    }

    @engine = new BlobPhysicsEngine(
      gravity: [0, 0]
      min: [0, 0]
      max: [1920, 1080]
      friction: 0.5
      bounce: 1.0
    )
    @players = new Array()

    @simulator =
      tickHandle: null
      lastTick: Date.now()
      accumulator: 0
      timestep: (1 / 10) * 1000


  run: ->
    @wss.on "connection", (ws) =>
      clientize(@, ws)

    @simulator.lastTick = Date.now()
    @gameTick()


  gameTick: ->
    now = Date.now()
    delta = (now - @simulator.lastTick) / 1000
    @simulator.accumulator += delta

    while @simulator.accumulator > @simulator.timestep
      @engine.integrate(@simulator.timestep)
      @simulator.accumulator -= @simulator.timestep

    @broadcastMessage "game:step", @engine.blobs

    @simulator.tickHandle = setTimeout (=> @gameTick()), @simulator.timestep
    @simulator.lastTick = now

  setPlayerTarget: (uuid, position) ->
    blobs = @engine.collectBlobsWith ownerId: uuid
    _.each blobs, (blob) ->
      distance = Math.sqrt(
        ((blob.position[0] - point[0]) * (blob.position[0] - point[0])) +
        ((blob.position[1] - point[1]) * (blob.position[1] - point[1]))
      )
      if distance > 10
        diff = _.map point, (axis, idx) ->
          (axis - blob.position[idx]) / distance
        blob.addForce diff


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
    @_sendMessageTo(client, compressed)


  _sendMessageTo: (client, message) ->
    try
      client.send(message)
    catch e
      console.log '_sendMessageTo', client.tmb

