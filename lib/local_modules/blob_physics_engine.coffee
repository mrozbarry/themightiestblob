
VerletSystem = require('verlet-system')
Point = require('verlet-point')
Constraint = require('verlet-constraint')
_ = require('lodash')

module.exports = class BlobPhysicsEngine
  constructor: (verletSystemOpts = {}) ->
    @world = VerletSystem(verletSystemOpts)
    @blobs = new Array()

    @accumulator = 0
    @timestep = (1 / 60)

    @callbacks =
      preSolve: new Array()
      collided: new Array()
      postSolve: new Array()

  addBlob: (ownerId, position, radius) ->
    blob = Point({
      position: position
      radius: radius
      mass: radius
    })
    blob.ownerId = ownerId
    @blobs.push blob
    blob

  collectBlobsWith: (attributes) ->
    return [] unless attributes? && _.isPlainObject(attributes)
    _.select @blobs, attributes

  removeBlobsWith: (attributes) ->
    return 0 unless attributes? && _.isPlainObject(attributes)
    oldLength = @blobs.length
    @blobs = _.reject @blobs, attributes
    oldLength - @blobs.length

  integrate: (deltaTime) ->
    unless @blobs.length
      return

    @accumulator += deltaTime
    while @accumulator > @timestep
      @world.integrate(@blobs, @timestep)
      @accumulator -= @timestep

  checkCollision: (a, b) ->
    xOverlapA = a.position[0] + a.radius + b.radius > b.position[0]
    xOverlapB = a.position[0] < b.position[0] + a.radius + b.radius
    xOverlap = xOverlapA && xOverlapB
    yOverlapA = a.position[1] + a.radius + b.radius > b.position[1]
    yOverlapB = a.position[1] < b.position[1] + a.radius + b.radius
    yOverlap = yOverlapA && yOverlapB

    minTouchDist = a.radius + b.radius

    if xOverlap && yOverlap && @distanceBetweenBlobs(a, b) < minTouchDist
      pointOfCollision = @calculateCollisionPoint(a, b)

      return false unless @emit 'preSolve', [a, b, pointOfCollision]
      constraint = Constraint [a, b], { stiffness: 0.8, restingDistance: (a.radius + b.radius)}

      if @emit('collided', [a, b, pointOfCollision])
        constraint.solve()

      @emit 'postSolve', [a, b, pointOfCollision]
      return true

    false

  distanceBetweenBlobs: (a, b) ->
    xSqrDiff = (a.position[0] - b.position[0]) * (a.position[0] - b.position[0])
    ySqrDiff = (a.position[1] - b.position[1]) * (a.position[1] - b.position[1])
    Math.sqrt(xSqrDiff + ySqrDiff)


  calculateCollisionPoint: (a, b) ->
    x = (a.position[0] * b.radius) + (b.position[0] * a.radius) /
      (a.radius + b.radius)

    y = (a.position[1] * b.radius) + (b.position[1] * a.radius) /
      (a.radius + b.radius)

    Point({
      position: [x, y]
    })

  # TODO: Do blobs bounce?  Probably not, but I need to do some testing to see if it makes sense
  # updateAccelerationOfBlobAgainstCollider: (blob, collider) ->
  #   vx = (blob.acceleration[0] * (blob.mass - collider.mass) + (2 * collider.mass * collider.acceleration[0])) / (blob.mass + collider.mass)
  #   vy = (blob.acceleration[1] * (blob.mass - collider.mass) + (2 * collider.mass * collider.acceleration[1])) / (blob.mass + collider.mass)
  #
  #   Point({
  #     position: [vx, vy]
  #   })
  #

  on: (callbackName, method) ->
    return unless @_callbackNameValid(callbackName)
    @callbacks[callbackName].push method

  off: (callbackName, method) ->
    return unless @_callbackNameValid(callbackName)
    _.pull @callbacks[callbackName], method

  emit: (callbackName, args) ->
    return unless @_callbackNameValid(callbackName)

    _.reduce @callbacks[callbackName], ((result, callback) ->
      return false unless result == true
      _.contains [undefined, true], cb.apply(@, args)
    ), true

  _callbackNameValid: (callbackName) ->
    _.contains ['preSolve', 'collided', 'postSolve'], callbackName

