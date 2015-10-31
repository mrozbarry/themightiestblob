
VerletSystem = require('verlet-system')
Point = require('verlet-point')
Constraint = require('verlet-constraint')
_ = require('lodash')

module.exports = class BlobPhysicsEngine
  constructor: (@timeStep = 1 / 30.0, verletSystemOpts = {}) ->
    @world = VerletSystem(verletSystemOpts)
    @owners = new Array()
    @blobs = new Array()

    @callbacks =
      preSolve: new Array()
      collided: new Array()
      postSolve: new Array()

  on: (callbackName, method) ->
    @callbacks[callbackName].push method

  off: (callbackName, method) ->
    _.pull @callbacks[callbackName], method

  emit: (callbackName, args) ->
    _.some @callbacks[callbackName], (cb) =>
      _.contains [undefined, true], cb.apply(@, args)

  addBlob: (ownerId, x, y, radius) ->
    return false unless ownerId?

    blob = Point({
      position: [x, y]
      radius: radius
      mass: Math.floor(Math.PI * Math.pow(radius, 2))
    })
    @blobs.push blob
    blob.ownerId = ownerId
    blob

  collectBlobs: (ownerId) ->
    return false unless ownerId?
    _.select @blobs, ownerId: ownerId

  integrate: (deltaTime) ->
    if @blobs.length > 0
      @world.integrate(@blobs, deltaTime)

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

      @emit 'preSolve', [a, b, pointOfCollision]
      a = @updateAccelerationOfBlobAgainstCollider(a, b)
      b = @updateAccelerationOfBlobAgainstCollider(b, a)

      @emit 'collided', [a, b, pointOfCollision]
      a.position[0] += a.acceleration[0]
      a.position[1] += a.acceleration[1]
      b.position[0] += b.acceleration[0]
      b.position[1] += b.acceleration[1]

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

  updateAccelerationOfBlobAgainstCollider: (blob, collider) ->
    vx = (blob.acceleration[0] * (blob.mass - collider.mass) + (2 * collider.mass * collider.acceleration[0])) / (blob.mass + collider.mass)
    vy = (blob.acceleration[1] * (blob.mass - collider.mass) + (2 * collider.mass * collider.acceleration[1])) / (blob.mass + collider.mass)

    blob.acceleration[0] = vx
    blob.acceleration[1] = vy
    blob

