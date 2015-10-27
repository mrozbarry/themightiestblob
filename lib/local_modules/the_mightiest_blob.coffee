
Player = require('./player')
Blob = require('./blob')
MathExt = require('./math_ext')
_ = require('lodash')

class TheMightiestBlob extends require('eventemitter3')
  constructor: (configuration) ->
    @lastTimeStep = null
    @timeoutHandle = null
    @configuration = _.extend {
      maxPlayers: 16
      speedDecayPerTick: (1 / 2)
      timeStep: (1.0 / 60.0) * 1000
      worldSize: 2000
      startBlobMass: 1
    }, configuration
    @players = new Array()

    @accumulator = 0

    @runSimulation()

  addPlayer: (player) ->
    unless player instanceof Player
      throw new Error('TheMightiestBlob.addPlayer: accepts only a single instance of class Player')

    if @configuration.maxPlayers >= 0 && @players.length >= @configuration.maxPlayers
      throw new Error('TheMightiestBlob.addPlayer: no player slots available')

    @players.push player
    @emit "game:players:change"
    @

  removePlayer: (player) ->
    @players = _.reject @players, uuid: player.uuid
    @emit "game:players:change"

  allPlayerBlobs: ->
    _.reduce @players, ((allBlobs, player) ->
      return allBlobs if player.uuid == null
      allBlobs.concat player.blobs
    ), new Array()

  blobTouchDepth: (a, b, bufferSpace = 0) ->
    edgeTouch = (a.radius() + b.radius() + bufferSpace) << 2
    squaredX = (b.position.x - a.position.x) << 2
    squaredY = (b.position.y - a.position.y) << 2
    squared = squaredX + squaredY
    return 0 if squared >= edgeTouch
    Math.abs(edgeTouch - squared)

  selectBlobsCollidingWithBlob: (blobs, testBlob, bufferSpace) ->
    return new Array() unless blobs.length > 0
    _.select blobs, (blob) ->
      @blobTouchDepth(blob, testBlob, bufferSpace) > 0

  anyBlobsCollidingWithBlob: (blobs, testBlob, bufferSpace = 0) ->
    return false unless blobs.length > 0
    for blob in blobs
      return true if @blobTouchDepth(blob, testBlob, bufferSpace) > 0

    false

  setPlayerTarget: (playerUuid, position) ->
    player = _.find @players, uuid: playerUuid

    return @ unless player

    player.target = new MathExt.Vector(
      position.x, position.y
    )

    @

  runSimulation: ->
    @accumulator = 0
    @lastTimeStep = Date.now()
    @gameStep(null)
    @

  pauseSimulation: ->
    if @timeoutHandle
      clearTimeout @timeoutHandle
    @timeoutHandle = null

  gameStepDelta: (timeStep) ->
    delta = 0
    delta = timeStep - @lastTimeStep if @lastTimeStep?
    @lastTimeStep = timeStep
    delta

  gameStep: ->
    @accumulator += @gameStepDelta(Date.now())
    while @accumulator > @configuration.timeStep
      @players = _.map @players, (player) =>
        player.update(@configuration)

      @accumulator -= @configuration.timeStep


    @emit 'game:state:change', @

    # This stops the browser from being
    # completely locked up!
    @timeoutHandle = setTimeout (=>
      @gameStep()
    ), @configuration.timeStep

module.exports = TheMightiestBlob

