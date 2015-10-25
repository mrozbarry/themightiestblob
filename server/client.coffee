Player = require('../lib/local_modules/player.coffee')
lz4 = require('lz4')

randomPosition = (game) ->
  new MathExt.Vector(
    Math.random() * game.configuration.wordSize
    Math.random() * game.configuration.worldSize
  )

module.exports = class Client extends require('eventemitter3')
  constructor: (@game, @socket) ->
    @state = 'ready'
    @player = null
    @lastOutgoing = null
    @lastIncoming = null

    @socket.on "message", (e) =>

    @socket.on "close", =>
      @leaveGame()

  destructor: ->
    @game.removePlayer(@player)

  sendMessage: (channel, data) ->
    message = JSON.stringify({
      channel: channel
      block: @lastOutgoing
      data: data
    })
    @lastOutgoing = md5.digest_s(message)
    @socket.send lz4.encode(message)

  processMessage: (message) ->
    switch message.channel
      when "client:broadcast:message" then @handleBroadcastMessage(message.data)
      when "client:send:input" then @handleSendInput(message.data)
      when "client:join" then @handleClientJoin(message.data)
      when "client:leave" then @handleClientLeave(message.data)

  joinGame: (name) ->
    if @player?
      throw new Error('Player.joinGame: cannot join a game when already in a game')

    @player = new Player(name)
    @player.addBlob(
      randomPosition(@game),
      @game.configuration.startBlobMass
    )
    playerBlob = @player.blobs[0]

    allPlayerBlobs = @game.allPlayerBlobs()

    while @game.anyBlobsCollidingWithBlob(allPlayerBlobs, playerBlob)
      @player
        .removeBlob(playerBlob)
        .addBlob(
          randomPosition(@game),
          @game.configuration.startBlobMass
        )
        .addBlob(randomPosition(@game))

      playerBlob = @player.blobs[0]

    @game.addPlayer @player

  leaveGame: ->
    if @player
      @game.removePlayer @player


