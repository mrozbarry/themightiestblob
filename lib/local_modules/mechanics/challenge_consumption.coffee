
module.exports = (engine) ->
  engine.on "collided", (a, b, constraint, pointOfCollision) ->
    # If either mass is infinity, then the mass cannot be challenged
    return true if _.includes [a.mass, b.mass], Infinity

