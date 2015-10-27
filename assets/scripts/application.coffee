WebSocket = require('ws')
lz4       = require('lzutf8')

JoinModal     = require('./components/join_modal/index')
World     = require('./components/world/index')

TheMightiestBlob = require('../../lib/local_modules/the_mightiest_blob')
game = new TheMightiestBlob()

module.exports = Component.create
  displayName: 'Application'

  socket: null

  getInitialState: ->
    uuid: null
    gameState:
      configuration: {}
      players: new Array()

  connectSocket: ->
    host = ["ws://", window.location.hostname]
    host = host.concat [":", window.location.port] if window.location.port != ""
    websocketHost = host.join('')

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

  joinGame: (name) ->
    @sendMessage "client:join",
      name: name

  leaveGame: ->
    @sendMessage "client:leave", {}

  setTarget: (position) ->
    console.log 'setTarget', position.x, position.y

  componentWillMount: ->
    @connectSocket()

  componentWillUnmount: ->
    @leaveGame()

  processMessage: (message) ->
    # console.log '>>> ', message.channel, message.data
    switch message.channel
      when "server:hello"
        @setState connected: true

      when "join:success"
        @setState uuid: message.data.uuid

      when "game:state:change"
        # console.debug 'state change', message.data
        @setState gameState: message.data

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
      World
        gameState: @state.gameState
        uuid: @state.uuid
        setTarget: @setTarget

  renderWaiting: ->
    React.DOM.div {},
      unless @state.uuid
        JoinModal
          joinGame: @joinGame
      'Connecting to server...'

