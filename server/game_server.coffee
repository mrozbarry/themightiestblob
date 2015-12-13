WebSocketServer = require("ws").Server
_ = require('lodash')
lz4 = require('lzutf8')

BlobPhysicsEngine = require('../lib/local_modules/blob_physics_engine')
clientize = require('./client')


module.exports = class
  constructor: (server) ->

    @engine = new BlobPhysicsEngine(
      gravity: [0, 0]
      min: [0, 0]
      max: [700, 700]
      friction: 0.5
      bounce: 1.0
    )
    @players = new Array()
    @blobs = new Array()

    _.each [0..100], (worldBlob) =>
      @spawnBlob()


    @simulator =
      tickHandle: null
      lastTick: Date.now()
      accumulator: 0
      timestep: (1 / 60)
      broadcastTime: 500
      nextBroadcast: Date.now()

    @wss = new WebSocketServer {
      server: server
      clientTracking: true
    }

  run: ->
    @wss.on "connection", (ws) =>
      clientize(@, ws)

    @simulator.lastTick = Date.now()
    @gameTick()


  gameTick: ->
    now = Date.now()
    delta = (now - @simulator.lastTick) / 1000
    @simulator.accumulator += delta

    collisions = 0
    while @simulator.accumulator > @simulator.timestep
      @engine.integrate(@blobs, @simulator.timestep)
      collisions += @engine.lastIntegrate.numberOfCollisions
      @simulator.accumulator -= @simulator.timestep


    if (new Date()).getTime() > @simulator.nextBroadcast
      @broadcastMessage "game:step", @getAllBlobs()
      @simulator.nextBroadcast = (new Date()).getTime() + @simulator.broadcastTime

    @simulator.tickHandle = setTimeout (=> @gameTick()), 1
    @simulator.lastTick = now


  getAllBlobs: ->
    _.map @blobs, @blobToPlainObject

  blobToPlainObject: (blob) ->
    position: _.map [0, 1], (axis) -> blob.position[axis]
    previous: _.map [0, 1], (axis) -> blob.previous[axis]
    acceleration: _.map [0, 1], (axis) -> blob.acceleration[axis]
    mass: blob.mass
    radius: blob.radius
    ownerId: blob.ownerId


  spawnBlob: (owner, position, mass) ->
    unless position
      position = [
        Math.random() * @engine.world.max[0]
        Math.random() * @engine.world.max[1]
      ]
    mass = parseInt(mass) || 10 + Math.floor((Math.random() * 100))
    @engine.addBlob(@blobs, owner, position, mass)

  setPlayerTarget: (uuid, point) ->
    @blobs = _.map @blobs, (blob) =>
      return blob unless blob.ownerId == uuid
      force = @engine.forceBlobTowards(blob, point)
      blob.addForce force
      blob

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
      try
        @_sendMessageTo(client, compressed)
      catch e
        console.log 'Problem sending to', client

  sendMessage: (client, channel, data) ->
    composed = JSON.stringify @composeMessage(channel, data)
    compressed = @compressMessage composed
    @_sendMessageTo(client, compressed)

  _sendMessageTo: (client, message) ->
    try
      client.send(message)
    catch e
      console.log '_sendMessageTo', client.tmb

