uuid = require('uuid')

module.exports = (server, socket) ->
  socket.tmb =
    uuid: uuid.v4()
    name: null
    target: [0, 0]

  socket.on "message", (data, flags) ->
    message = server.decodeMessage(data)

    switch message.channel
      when "client:join"
        socket.tmb.name = message.data.name
        position = [
          Math.random() * server.engine.world.max[0]
          Math.random() * server.engine.world.max[1]
        ]
        server.engine.addBlob socket.tmb.uuid, position, message.data.mass || 10

      when "client:leave"
        server.engine.removeBlobsWith(ownerId: socket.tmb.uuid)
        socket.close()

      when "client:target"
        server.setPlayerTarget(socket.tmb.euid, message.data)

  socket.on "close", ->
    socket.tmb.connected = false
    # TODO: remove player from simulation

  server.sendMessage(socket, 'server:hello', 'tmb')

