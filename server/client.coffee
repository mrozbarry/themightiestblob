uuid = require('uuid')
_ = require('lodash')
please = require('pleasejs')

module.exports = (server, socket) ->
  uuid = uuid.v4()
  socket.tmb =
    uuid: uuid
    name: null
    target: [0, 0]
    colour: please.make_color()
    team: null
    respawn: ->
      server.removeBlobsOfOwner(uuid)
      server.broadcastAllBlobs()

  server.sendMessage(socket, "server:info", server.engine.world)

  socket.on "message", (data, flags) ->
    message = server.decodeMessage(data)

    switch message.channel
      when "client:join"
        socket.tmb.name = message.data.name

        server.spawnBlob socket.tmb.uuid, null, message.data.mass

        server.sendMessage(socket, "client:info", socket.tmb)

        clients = _.map server.wss.clients, (client) -> client.tmb
        server.broadcastMessage "client:list", clients
        server.broadcastAllBlobs(true)

      when "client:leave"
        server.engine.removeBlobsWith(ownerId: socket.tmb.uuid)
        socket.close()

      when "client:target"
        socket.tmb.target = message.data

        if message.data
          server.setPlayerTarget(socket.tmb.uuid, message.data)

        _.each server.wss.clients, (client) ->
          server.sendMessage(client, "game:inputs", _.pick(socket.tmb, ['uuid', 'target']))

  socket.on "close", ->
    server.engine.removeBlobsWith(ownerId: socket.tmb.uuid)


