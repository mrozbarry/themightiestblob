WebSocket = require('ws')
lz4       = require('lzutf8')
Login     = require('./components/login/index')
World     = require('./components/world/index')

TheMightiestBlob = require('../../lib/local_modules/the_mightiest_blob')
game = new TheMightiestBlob()

module.exports = Component.create
  displayName: 'Application'

  socket: null

  getInitialState: ->
    userName: 'demo'
    userId: null
    connected: false
    gameState:
      configuration: {}
      players: new Array()

  connectSocket: ->
    host = ["ws://", window.location.hostname]
    host = host.concat [":", window.location.port] if window.location.port != ""
    websocketHost = host.join('')

    @socket = new WebSocket(websocketHost)

    @socket.onopen = =>
      console.debug 'App.didMount.socket.open'

    @socket.onerror = (e) =>
      console.error 'App.didMount.socket.error', e

    @socket.onclose = =>
      console.warn 'App.didMount.socket.close'
      @setState connected: false, userId: null

    @socket.onmessage = (e) =>
      raw = lz4.decompress e.data,
        inputEncoding: 'Base64'
        outputEncoding: 'String'
      @processMessage(JSON.parse(raw))

  createMessage: (channel, data) ->
    JSON.stringify({
      channel: channel
      block: 'TODO: Store message'
      data: data
    })

  sendMessage: (channel, data) ->
    raw = @createMessage(channel, data)
    message = lz4.compress raw,
      outputEncoding: 'Base64'

    @socket.send message

  componentWillMount: ->
    @connectSocket()

  processMessage: (message) ->
    console.log 'processMessage', message.channel, message.data
    switch message.channel
      when "server:hello"
        @sendMessage "client:join",
          name: @state.userName

        @setState connected: true

      when "game:state:change"
        console.debug 'state change', message.data
        @setState gameState: message.data


  render: ->
    if @state.connected
      @renderConnected()
    else
      @renderWaiting()

  renderConnected: ->
    World
      gameState: @state.gameState

  renderWaiting: ->
    React.DOM.div {}, 'Connecting to server...'

