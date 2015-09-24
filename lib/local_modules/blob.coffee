
class Blob
  constructor: (player, @position = new MathExt.Vector(), @mass = 25) ->
    @playerUuid = player.uuid
    @position = new MathExt.Vector()

  simulate: (players) ->
    player = _.find players, uuid: @playerUuid
    return @ unless player
    unit = player.target.normal(@position)
    @position = @position.add(
      unit.multiply(1000 / @mass)
    )
    @

module.exports = Blob

