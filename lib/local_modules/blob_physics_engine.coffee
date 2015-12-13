
VerletSystem = require('verlet-system')
Point = require('verlet-point')
Constraint = require('verlet-constraint')
_ = require('lodash')
uuid = require('uuid')

module.exports = class BlobPhysicsEngine
  constructor: (options = {}) ->
    @world = VerletSystem(options.verlet)

    @accumulator = 0
    @timestep = (1 / 60)
    @time = 0

    @callbacks =
      preIntegrate: new Array()
      preSolve: new Array()
      collided: new Array()
      postSolve: new Array()
      postIntegrate: new Array()

    @lastIntegrate =
      numberOfCollisions: 0
      collisions: []

  registerPlugin: (register) ->
    register(@)

  addBlob: (blobs, ownerId, position, radius, options = {isConsumable: true, isMovable: true}) ->
    blob = Point({
      position: position
      radius: radius
      mass: if options.isMovable? then radius else Infinity
    })
    blob.id = uuid()
    blob.ownerId = ownerId
    blob.isConsumable = options.isConsumable
    blob.meta = {}
    blobs.push blob
    blob

  forceBlobTowards: (blob, target) ->
    distance = @distanceBetweenPoints(blob.position, target)
    return [0, 0] if distance <= (blob.radius * .75)

    _.map target, (axis, idx) ->
      (axis - blob.position[idx]) / (blob.mass)


  collectBlobsWith: (blobs, attributes) ->
    return [] unless attributes? && _.isPlainObject(attributes)
    _.select blobs, attributes

  removeBlobsWith: (blobs, attributes) ->
    return blobs unless attributes? && _.isPlainObject(attributes)
    blobs = _.reject blobs, attributes

  integrate: (blobs, deltaTime) ->
    unless blobs.length
      return blobs

    @accumulator += deltaTime
    while @accumulator > @timestep
      @time += @timestep
      @world.integrate(blobs, @timestep)
      blobs = _.reject blobs, (b) -> b.mass < 5
      # blobs = @collisions(blobs, @time)
      @accumulator -= @timestep

    blobs

  testCollision: (a, b) ->
    return false if a == b

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

      if @emit('collided', [a, b, constraint, pointOfCollision])
        constraint.solve()

      @emit 'postSolve', [a, b, pointOfCollision]
      return true

    false

  distanceBetweenPoints: (a, b) ->
    xSqrDiff = (a[0] - b[0]) * (a[0] - b[0])
    ySqrDiff = (a[1] - b[1]) * (a[1] - b[1])
    Math.sqrt(xSqrDiff + ySqrDiff)

  distanceBetweenBlobs: (a, b) ->
    @distanceBetweenPoints(a.position, b.position)

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

