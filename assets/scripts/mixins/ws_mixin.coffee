WebSocket = require('ws')
lz4       = require('lzutf8')

module.exports =
  socket: null

  connectSocket: ->
    isSecure = window.location.protocol == "https:"
    host = [
      if isSecure then "wss://" else "ws://"
      window.location.hostname
    ]
    host = host.concat [":", window.location.port] if window.location.port != ""
    websocketHost = host.join ''

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

  disconnectSocket: ->
    @socket.close()
    @socket = null

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

