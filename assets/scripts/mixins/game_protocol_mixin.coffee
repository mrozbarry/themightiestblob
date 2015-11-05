
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

  sendTarget: (position) ->
    return unless @state.uuid
    @sendMessage "client:target", position


