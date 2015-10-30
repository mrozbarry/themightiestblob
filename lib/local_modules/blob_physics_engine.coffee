
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

    @world.integrate(blobs, deltaTime) if blobs.length > 0
    # TODO: SAT to find collisions



