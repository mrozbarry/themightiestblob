
interpolateMotion = require('../interpolate_motion')
Player = require('./player')
Blob = require('./blob')

class TheMightiestBlob
  @EVENTS:
    PRERENDER: 'tmb:render:before'
    RENDER: 'tmb:render:present'
    POSTRENDER: 'tmb:render:after'
    PLAYER_JOIN: 'tmb:player:join'
    PLAYER_LEAVE: 'tmb:player:leave'
    PLAYER_INPUT: 'tmb:player:input'
    PLAYER_LIST: 'tmb:player:list'

  constructor: ->
    @lastTimeStep = null
    @animationFrameHandle = null
    @blobs = new Array()
    @players = new Array()
    @inputPlayerUuid = null
    @subscribe(TheMightiestBlob.EVENTS.PLAYER_JOIN, @addPlayer)

  subscribe: (eventName, method) ->
    addEventListener(eventName, _.bind(method, @), true)

  unsubscribe: (eventName, method) ->
    removeEventListener(eventName, _.bind(method, @))

  publish: (eventName, payload) ->
    evt = new CustomEvent eventName,
      detail: payload
    dispatchEvent(evt)

  addPlayer: (event) ->
    p = new Player(event.detail.name)
    b = new Blob(p)
    @players.push p
    @blobs.push b
    @publish TheMightiestBlob.EVENTS.PLAYER_LIST, @

  runSimulation: ->
    @gameStep(null)

  pauseSimulation: ->
    if @animationFrameHandle
      cancelAnimationFrame(@animationFrameHandle)
    @animationFrameHandle = null

  gameStepDelta: (timeStep) ->
    delta = 0
    delta = timeStep - @lastTimeStep if @lastTimeStep?
    @lastTimeStep = timeStep
    delta

  gameStep: (timeStep) ->
    delta = @gameStepDelta(timeStep)

    @publish TheMightiestBlob.EVENTS.PRERENDER, @
    @blobs = @simulateEachBlob(@blobs, @players)
    @publish TheMightiestBlob.EVENTS.POSTRENDER, @

    @animationFrameHandle = requestAnimationFrame(
      _.bind(@gameStep, @)
    )

  simulateEachBlob: (blobs, players) ->
    _.map blobs, (blob) =>
      player = _.find players, uuid: blob.playerUuid
      return blob unless player
      blob.simulate(player)

module.exports = TheMightiestBlob

