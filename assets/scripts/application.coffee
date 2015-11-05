sillyname = require('sillyname')
uuid = require('uuid')

JoinModal     = require('./components/join_modal/index')
World     = require('./components/world/index')

WsMixin = require('./mixins/ws_mixin')
GameProtocolMixin = require('./mixins/game_protocol_mixin')

BlobPhysicsEngine = require('../../lib/local_modules/blob_physics_engine')
Point = require('verlet-point')

initialUuid = null

module.exports = Component.create
  displayName: 'Application'

  mixins: [WsMixin, GameProtocolMixin]

  buildEngine: (options = { gravity: [0, 0], min: [0, 0], max: [1920, 1080], friction: 0.5, bounce: 1.0}) ->
    @engine = new BlobPhysicsEngine(options)

  processMessage: (message) ->
    switch message.channel
      when "server:info"
        @setState worldAttrs: message.data, =>
          @lastUpdate = Date.now()
          @buildEngine(message.data)
          @stepSimulation(@engine.blobs)

      when "client:info"
        console.info 'info', message.data
        @setState uuid: message.data.uuid

      when "client:kick"
        @setState uuid: null, =>
          @disconnectSocket()

      when "client:list"
        console.info 'list', message.data
        @setState players: message.data

      when "game:step"
        return unless @engine?
        if message.data instanceof Array
          @engine.blobs = _.map message.data, (blob) ->
            pnt = Point(blob)
            pnt.ownerId = blob.ownerId
            pnt

  stepSimulation: (blobs) ->
    return unless @engine?

    { lastUpdate } = @state
    now = Date.now()

    if lastUpdate > 0
      delta = (now - lastUpdate) / 1000.0
      @lastUpdate = now

      @engine.blobs = blobs
      @engine.integrate(delta)

    # Step simulation
    @setState lastUpdate: now

  setTarget: (point) ->
    blobs = @engine.collectBlobsWith ownerId: @state.uuid
    _.each blobs, (blob) ->
      distance = Math.sqrt(
        ((blob.position[0] - point[0]) * (blob.position[0] - point[0])) +
        ((blob.position[1] - point[1]) * (blob.position[1] - point[1]))
      )
      if distance > 10
        diff = _.map point, (axis, idx) ->
          (axis - blob.position[idx]) / distance
        blob.addForce diff
    @sendTarget point

  getInitialState: ->
    uuid: initialUuid
    previous:
      name: sillyname()
      mass: 1

    lastUpdate: null

    worldAttrs:
      min: [0, 0]
      max: [1920, 1080]
      gravity: [0, 0]

    players: _.map [initialUuid], (id, rank) ->
      uuid: id
      name: sillyname()
      rank: rank + 1

  componentWillMount: ->
    @engine = null
    @connectSocket()

  componentWillUnmount: ->
    @leaveGame()
    @engine = null

  # TODO: Disable this after testing ---------------------------------------------
  # componentDidMount: ->
  #   @buildEngine()
  #   @engine.addBlob initialUuid, [0, 0], 50
  #   @stepSimulation(@engine.blobs)

  componentDidUpdate: ->
    # Not sure if this timeout is neccessary
    # I just wanted to give JS enough time
    # to breath.  Might be important on slower
    # computers?
    setTimeout (=> @stepSimulation(@engine.blobs)), 1

  render: ->
    React.DOM.div {},
      unless @state.uuid
        JoinModal
          joinGame: @joinGame
          previous: @state.previous
      World
        uuid: @state.uuid
        worldAttrs: @state.worldAttrs
        players: @state.players
        blobs: if @engine? then @engine.blobs else []
        setTarget: @setTarget

