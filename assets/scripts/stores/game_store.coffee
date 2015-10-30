BaseStore = require('./base_store')
ClientConnection = require('../lib/client_connection_class')

gameState = {
  uuid: null
}

class GameStore extends BaseStore
  constructor: ->
    super()
    @connection = new ClientConnection()
    Dispatcher.register(@handleGameAction)

  handleGameAction: (payload) ->
    switch payload.actionType
      when 'player:join' then @handlePlayerJoin(payload)
      when 'player:leave' then @handlePlayerLeave(payload)
      when 'player:input' then @handlePlayerInput(payload)

  handlePlayerJoin: (payload) ->
    @connection
    @connection.socketSend 'world:join', userName: payload.userName

  handlePlayerLeave: (payload) ->

  handlePlayerInput: (payload) ->

module.exports = new BlobStore()

