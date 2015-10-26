Player = require('../lib/local_modules/player')
MathExt = require('../lib/local_modules/math_ext')
lz4 = require('lzutf8')
md5 = require('js-md5')
uuid = require('uuid')

randomPosition = (game) ->
  new MathExt.Vector(
    Math.random() * game.configuration.wordSize
    Math.random() * game.configuration.worldSize
  )

module.exports = class Client
  constructor: (@server, @socket) ->
    @uuid = uuid.v4()
    @state = 'ready'
    @player = null
    @lastOutgoing = null
    @lastIncoming = null

    @socket.on "message", (data, flags) =>
      message = @server.decompressMessage(data)
      @processMessage(message)

    @socket.on "close", =>
      @handleClientLeave(null)

    @socket.send(
      @server.encodeMessage('server:hello', 'tmb')
    )

  destructor: ->
    @server.game.removePlayer(@player)

  processMessage: (message) ->
    switch message.channel
      when "client:broadcast:message" then @handleBroadcastMessage(message.data)
      when "client:send:input" then @handleSendInput(message.data)
      when "client:join" then @handleClientJoin(message.data)
      when "client:leave" then @handleClientLeave(message.data)

  handleSetInput: (payload) ->

  handleBroadcastMessage: (payload) ->
    message = @server.encodeMessage "client:broadcast:message",
      playerUuid: @player.uuid
      text: payload.text
      unverified: true

    @server.broadcastMessage(message)

  handleClientJoin: (payload) ->
    if @player?
      throw new Error('Player.joinGame: cannot join a game when already in a game')

    @player = new Player(payload.name)
    @player.addBlob(
      randomPosition(@server.game),
      @server.game.configuration.startBlobMass
    )
    playerBlob = @player.blobs[0]

    allPlayerBlobs = @server.game.allPlayerBlobs()

    while @server.game.anyBlobsCollidingWithBlob(allPlayerBlobs, playerBlob)
      @player
        .removeBlob(playerBlob)
        .addBlob(
          randomPosition(@server.game),
          @server.game.configuration.startBlobMass
        )
        .addBlob(randomPosition(@server.game))

      playerBlob = @player.blobs[0]

    @server.game.addPlayer @player

  handleClientLeave: (payload) ->
    if @player
      @server.game.removePlayer @player
    @socket.close()
    @server.removeClientWithUuid(@uuid)


