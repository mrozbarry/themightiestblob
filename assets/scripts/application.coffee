sillyname = require('sillyname')
uuid = require('uuid')

JoinModal     = require('./components/join_modal/index')
World     = require('./components/world/index')

WsMixin = require('./mixins/ws_mixin')
GameProtocolMixin = require('./mixins/game_protocol_mixin')

BlobPhysicsEngine = require('../../lib/local_modules/blob_physics_engine')
verletDefaults = require('../../lib/local_modules/verlet_defaults')
Point = require('verlet-point')


requestAnimationFrame =
  window.requestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame or
  (renderMethod) ->
    setTimeout(renderMethod, 10 / 6)

module.exports = Component.create
  displayName: 'Application'

  mixins: [WsMixin, GameProtocolMixin]

  getInitialState: ->
    uuid: null
    previous:
      name: ''
      mass: 10

    worldAttrs: verletDefaults

    players: []

  blobs: new Array()

  buildEngine: (options = verletDefaults) ->
    @engine = new BlobPhysicsEngine(
      verlet: options
    )

  processMessage: (message) ->
    switch message.channel
      when "server:info"
        @setState worldAttrs: message.data, =>
          @blobs = new Array()
          @buildEngine(message.data)
          @setState lastUpdate: Date.now(), =>
            @stepSimulation()

      when "client:info"
        @setState uuid: message.data.uuid

      when "client:kick"
        @setState uuid: null, =>
          @disconnectSocket()

      when "client:list"
        @setState players: message.data

      when "game:step"
        return unless @engine?
        if message.data instanceof Array
          @blobs = _.map message.data, (blob) ->
            pnt = Point(blob)
            pnt.ownerId = blob.ownerId
            pnt

      when "game:inputs"
        inputs = message.data
        @blobs = @retargetBlobsFromInput(@blobs, message.data)

  retargetBlobsFromInput: (blobs, input) ->
    _.map blobs, (blob) =>
      return blob unless blob.ownerId == input.uuid

      force = @engine.forceBlobTowards(blob, input.target)
      blob.addForce force

      blob


  stepSimulation: (now) ->
    return unless @engine?

    if @state.lastUpdate > 0
      delta = (now - @state.lastUpdate) / 1000.0

      @blobs = @engine.integrate(@blobs, delta)

    # Step simulation
    requestAnimationFrame ((timestamp)=> @stepSimulation(timestamp))
    @setState lastUpdate: now

  setTarget: (point) ->
    return unless @state.uuid
    me = _.find @state.players, uuid: @state.uuid
    if point
      if point[0] != me.target[0] && point[1] != me.target[1]
        @sendTarget point
    else
      @sendTarget null

  componentWillMount: ->
    @engine = null
    @connectSocket()

  componentWillUnmount: ->
    @leaveGame()
    @engine = null

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
        blobs: @blobs
        setTarget: @setTarget

