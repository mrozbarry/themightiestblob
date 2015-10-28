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

  calculateVelocityForBlob: (blob) ->
    diff = @target.subtract(blob.position)
    dist = @target.distance(blob.position)
    if dist < 5
      blob.velocity = new MathExt.Vector()

    else
      direction = diff.divide(dist)

      blob.velocity = direction.multiply(Math.max(Math.min(dist, 100), 1) / 2).divide(blob.mass * 2)
    blob

  update: (configuration) ->
    @blobs = _.map @blobs, (blob) =>
      nextBlob = @calculateVelocityForBlob(blob)
      nextBlob.update(configuration)
      nextBlob

    @

  splitAllBlobs: ->
    newBlobs = _.compact _.map @blobs, (blob) =>
      newMass = Math.floor(blob.mass / 2)
      return null if newMass < 1
      blob.mass = newMass

      newBlob = new Blob(@colour, @position, newMass)
      newBlob

    @blobs = @blobs.concat(newBlobs)



module.exports = Player

