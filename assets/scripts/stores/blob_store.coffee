BaseStore = require('./base_store')

class BlobStore extends BaseStore
  constructor: ->
    super()
    Dispatcher.register(@handleDemoAction)

  handleBlobAction: (payload) ->
    switch payload.actionType
      when 'blob-move' then @handleBlobMove(payload)

  handleBlobMove: (payload) ->

module.exports = new BlobStore()

