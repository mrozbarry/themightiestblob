
VerletSystem = require('verlet-system')
Point = require('verlet-point')
Constraint = require('verlet-constraint')
_ = require('lodash')

module.exports = class BlobPhysicsEngine
  constructor: (@timeStep = 1 / 30.0, verletSystemOpts = {}) ->
    @world = VerletSystem(verletSystemOpts)
    @owners = []
    @resetQueuedSteps()

  resetQueuedSteps: ->
    @accumulator = 0
    @lastSimulationStep = Date.now()

  findOrCreateOwner: (ownerId) ->
    return false unless ownerId?
    existing = _.find @owners, id: ownerId
    return existing if existing?

    owner = { id: ownerId, blobs: new Array() }
    @owners.push owner
    owner

  addBlob: (ownerId, x, y, radius) ->
    owner = @findOrCreateOwner(ownerId)
    return false unless owner

    blob = Point({
      position: [x, y]
      radius: radius
      mass: Math.floor(Math.PI * Math.pow(radius, 2))
    })
    owner.blobs.push blob
    blob

  collectBlobs: ->
    _.reduce @owners, ((blobs, owner) ->
      blobs.concat(owner.blobs)
    ), new Array()

  update: ->
    now = Date.now()
    deltaTime = now - @lastSimulationStep
    @integrate(deltaTime)
    @lastSimulationStep = now

  integrate: (deltaTime) ->
    blobs = @collectBlobs()

    if blobs.length > 0
      @world.integrate(blobs, deltaTime)

  checkCollision: (a, b) ->
    xOverlapA = a.position[0] + a.radius + b.radius > b.x
    xOverlapB = a.position[0] < b.position[0] + a.radius + b.radius
    xOverlap = xOverlapA && xOverlapB
    yOverlapA = a.position[1] + a.radius + b.radius > b.position[1]
    yOverlapB = a.position[1] < b.position[1] + a.radius + b.radius
    yOverlap = yOverlapA && yOverlapB

    minTouchDist = a.radius + b.radius

    if xOverlap && yOverlap && @distanceBetweenBlobs(a, b) < minTouchDist
      pointOfCollision = @calculateCollisionPoint(a, b)
      # Do pre-collision cb
      a = @updateAccelerationOfBlobAgainstCollider(a, b)
      b = @updateAccelerationOfBlobAgainstCollider(b, a)
      # Do collided cb
      a.position[0] += a.acceleration[0]
      a.position[1] += a.acceleration[1]
      b.position[0] += b.acceleration[0]
      b.position[1] += b.acceleration[1]
      # Do post collided cb

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

