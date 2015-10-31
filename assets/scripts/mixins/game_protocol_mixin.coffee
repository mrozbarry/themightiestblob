
module.exports =
  joinGame: (name, mass) ->
    @sendMessage "client:join",
      name: name
      mass: mass

    @setState previous: {
      name: name
      mass: mass
    }

  leaveGame: ->
    @sendMessage "client:leave", {}

  setTarget: (position) ->
    return unless @state.uuid
    @sendMessage "client:target", position

  setSplit: ->
    return unless @state.uuid
    # @sendMessage "client:split", {}

