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
    blob = new Blob(@colour, position, mass)
    @blobs.push blob

    @

  removeBlob: (blob) ->
    @blobs = _.reject @blobs, uuid: blob.uuid

    @

  calculateVelocityFromTarget: (blob) ->
    diff = @target.subtract(blob.position)
    dist = @target.distance(blob.position)
    if dist < 0.1
      blob.velocity = new MathExt.Vector()
    else
      direction = diff.divide(dist)

      blob.velocity = direction.divide(blob.mass)
    blob

  update: (configuration) ->
    @blobs = _.map @blobs, (blob) =>
      @calculateVelocityFromTarget(blob)
        .update(configuration)

    @

module.exports = Player

