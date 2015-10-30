
class ClientConnection
  constructor: (@messageQueueCallback) ->
    @socket = null
    @channelCallbacks = {}
    @ready = false
    @sendQueue = []

  subscribe: (channel, callback) ->
    @channelCallbacks[channel] ||= new Array(1)
    @channelCallbacks[channel].push callback

  unsubscribe: (channel, callback) ->
    return unless @channelCallbacks[channel]
    return unless @channelCallbacks[channel].length > 0

    _.pull(@channelCallbacks[channel], callback)

  emit: (channel, messageData) ->
    return unless @channelCallbacks[channel]
    return unless @channelCallbacks[channel].length > 0

    _.each @channelCallbacks[channel], (callback) ->
      callback(channel, messageData)

  connect: ->
    @messageId = 0
    @socket = new Websocket("ws://#{window.location.host}"
    @socket.onmessage = @socketMessage
    @socket.onclose = @socketClose
    @socket.onopen = @socketOpen

  disconnect: ->
    @socket.close()
    delete @socket
    @socket = null

  socketMessage: (event) ->
    message = JSON.parse(event.data)
    messageData = JSON.parse(lz4.decode(message.data))
    switch(message.channel)
      when 'server:ping'
        console.log 'Server Ping', messageData
        @socketSend 'server:ping', Date.now()

      when 'world:join'
        console.log 'World Join', messageData

      when 'world:update'
        console.log 'World Update', messageData

      when 'world:kick'
        console.log 'World Kick', messageData
        @socket.close()

    @emit(message.channel, messageData)

  socketClose: ->
    @ready = false
    delete @sendQueue if @sendQueue
    @sendQueue = null
    console.debug 'ClientConnetion.socketClose', arguments

  socketOpen: ->
    @ready = true
    console.debug 'ClientConnection.socketOpen', arguments

    for message in @sendQueue
      @socket.send message
    delete @sendQueue
    @sendQueue = null

  socketSend: (channel, data) ->
    message = JSON.stringify({
      channel: channel
      messageId: @messageId++
      data: lz4.encode(JSON.stringify(data))
    })


    unless @ready
      console.debug 'ClientConnection.socketSend(delayed)', arguments
      @sendQueue.push message
      return

    console.debug 'ClientConnection.socketSend(immediate)', arguments
    @socket.send message

module.exports = ClientConnection

