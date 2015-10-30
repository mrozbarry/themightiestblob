uuid = require('uuid')
Blob = require('./blob')
MathExt = require('./math_ext')
_ = require('lodash')

randomColour = ->
  rgb = _.sample [0...256], 3
  r: rgb[0]
  g: rgb[1]
  b: rgb[2]

class Player
  constructor: (@name = 'unnamed') ->
    @uuid = uuid.v4()
    @target = new MathExt.Vector(0, 0)
    @colour = randomColour()
    @blobs = new Array()

  addBlob: (position = (new MathExt.Vector()), mass = 1) ->
    @blobs.push new Blob(@colour, position, mass)

    @

  removeBlob: (blob) ->
    @blobs = _.reject @blobs, uuid: blob.uuid

    @

  collisionList: (blob, otherBlobs) ->
    _.select otherBlobs, (otherBlob) ->
      return false if otherBlob.uuid == blob.uuid
      smallestDistance = blob.radius() + otherBlob.radius()
      dist = blob.position.distance(otherBlob.position)

      if dist < smallestDistance
        unit = blob.position.subtract(otherBlob.position) #.divide(dist).multiply(smallestDistance)

        unit = new MathExt.Vector(smallestDistance, smallestDistance) unless dist

        blob.velocity = blob.velocity.add(unit)
        otherBlob.velocity = otherBlob.velocity.subtract(unit)

        true
      else
        false


  calculateVelocityForBlob: (blob, otherBlobs) ->
    force = new MathExt.Vector()

    dist = @target.distance(blob.position)
    if dist >= 5
      diff = @target.subtract(blob.position)
      direction = diff.divide(dist)

      force = direction
        .multiply(Math.max(Math.min(dist, 200), 1))
        .divide(blob.mass)

    blob.velocity = blob.velocity.add(force)

    blob

  update: (configuration, allBlobs) ->
    @blobs = _.map @blobs, (blob) =>
      collisionBlobs = _.reject allBlobs, uuid: blob.uuid
      nextBlob = @calculateVelocityForBlob(blob, collisionBlobs)
      # collisions = @collisionList(blob, allBlobs)
      nextBlob.update(configuration)
      nextBlob

    @

  splitAllBlobs: ->
    newBlobs = _.compact _.map @blobs, (blob) =>
      newMass = Math.floor(blob.mass / 2)
      return null if newMass < 1
      blob.mass = newMass

      newBlob = new Blob(blob.colour, blob.position, newMass)
      # newBlob.velocity = blob.velocity.multiply(2)
      newBlob

    @blobs = @blobs.concat(newBlobs)



module.exports = Player

