WebSocket = require('ws')
lz4       = require('lzutf8')
sillyname = require('sillyname')

JoinModal     = require('./components/join_modal/index')
World     = require('./components/world/index')

TheMightiestBlob = require('../../lib/local_modules/the_mightiest_blob')
game = new TheMightiestBlob()

module.exports = Component.create
  displayName: 'Application'

  socket: null

  getInitialState: ->
    uuid: null
    previous:
      name: sillyname()
      mass: 1

    gameState:
      configuration: {}
      players: new Array()

    lastGameState: null

  connectSocket: ->
    isSecure = window.location.protocol == "https:"
    console.debug 'Application.connectSocket', window.location.protocol, isSecure
    host = [
      if isSecure == "https:" then "wss://" else "ws://"
      window.location.hostname
    ]
    host = host.concat [":", window.location.port] if window.location.port != ""
    websocketHost = host.join ''
    console.debug ' ->', websocketHost

    @socket = new WebSocket(websocketHost)

    @socket.onopen = =>
      console.debug 'socket.open'

    @socket.onerror = (e) =>
      console.error 'socket.error', e

    @socket.onclose = =>
      console.warn 'socket.close'
      @setState @getInitialState(), =>
        setTimeout (=>
          @connectSocket()
        ), 5000

    @socket.onmessage = (e) =>
      raw = lz4.decompress e.data,
        inputEncoding: 'Base64'
        outputEncoding: 'String'
      @processMessage(JSON.parse(raw))

  createMessage: (channel, data) ->
    JSON.stringify({
      channel: channel
      data: data
    })

  sendMessage: (channel, data) ->
    raw = @createMessage(channel, data)
    # console.log '<<< ', raw
    message = lz4.compress raw,
      outputEncoding: 'Base64'

    @socket.send message

  joinGame: (name, mass) ->
    @sendMessage "client:join",
      name: name
      mass: mass

    @setState previous: {
      name: name
      mass: mass
    }

  leaveGame: ->
    @sendMessage "client:leave", {}

  setTarget: (position) ->
    return unless @state.uuid
    @sendMessage "client:target", position

  setSplit: ->
    return unless @state.uuid
    # @sendMessage "client:split", {}

  componentWillMount: ->
    @connectSocket()

  componentWillUnmount: ->
    @leaveGame()

  processMessage: (message) ->
    switch message.channel
      when "server:hello"
        @setState connected: true

      when "join:success"
        @setState uuid: message.data.uuid

      when "game:state:change"
        # console.debug 'state change', message.data
        lastGameState = @state.gameState
        @setState gameState: message.data, lastGameState: lastGameState

  render: ->
    if @socket.readyState == WebSocket.prototype.OPEN
      @renderConnected()
    else
      @renderWaiting()

  renderConnected: ->
    React.DOM.div {},
      unless @state.uuid
        JoinModal
          joinGame: @joinGame
          previous: @state.previous
      World
        gameState: @state.gameState
        lastGameState: @state.lastGameState
        uuid: @state.uuid
        setTarget: @setTarget
        setSplit: @setSplit

  renderWaiting: ->
    React.DOM.div {},
      unless @state.uuid
        JoinModal
          joinGame: @joinGame
          previous: @state.previous
      'Connecting to server...'

