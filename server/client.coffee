Player = require('../lib/local_modules/player')
MathExt = require('../lib/local_modules/math_ext')
lz4 = require('lzutf8')
md5 = require('js-md5')
uuid = require('uuid')

module.exports = (server, socket) ->
  socket.tmb =
    uuid: uuid.v4()
    connected: true
    playerUuid: null

  socket.on "message", (data, flags) ->
    message = server.decodeMessage(data)

    switch message.channel
      when "client:broadcast:chat"
        server.broadcastMessage "server:broadcast:chat",
          playerUuid: @player.uuid
          text: payload.text

      when "client:join"
        player = server.newPlayer(socket, message.data.name, message.data.mass)
        socket.tmb.playerUuid = player.uuid

      when "client:leave"
        socket.tmb.connected = false
        server.removePlayer(socket.tmb.playerUuid)
        socket.close()

      when "client:target"
        server.setPlayerTarget(socket.tmb.playerUuid, message.data)

      when "client:split"
        server.setPlayerSplit(socket.tmb.playerUuid)

  socket.on "close", ->
    socket.tmb.connected = false
    server.removePlayer(socket.tmb.playerUuid)

  server.sendMessage(socket, 'server:hello', 'tmb')

