uuid = require('uuid')
_ = require('lodash')
please = require('pleasejs')

module.exports = (server, socket) ->
  socket.tmb =
    uuid: uuid.v4()
    name: null
    target: [0, 0]
    colour: please.make_color()

  socket.on "message", (data, flags) ->
    message = server.decodeMessage(data)

    switch message.channel
      when "client:join"
        socket.tmb.name = message.data.name
        position = [
          Math.random() * server.engine.world.max[0]
          Math.random() * server.engine.world.max[1]
        ]
        server.engine.addBlob socket.tmb.uuid, position, parseInt(message.data.mass) || 10
        server.sendMessage(socket, "client:info", socket.tmb)

        clients = _.map server.wss.clients, (client) -> client.tmb
        server.broadcastMessage "client:list", clients

      when "client:leave"
        server.engine.removeBlobsWith(ownerId: socket.tmb.uuid)
        socket.close()

      when "client:target"
        server.setPlayerTarget(socket.tmb.uuid, message.data)

  socket.on "close", ->
    # TODO: remove player from simulation

  server.sendMessage(socket, 'server:info', server.engine.world)

