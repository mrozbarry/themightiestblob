MathExt = require('./math_ext')
uuid = require('uuid')

randomColour = ->
  rgb = _.sample [0...256], 3
  r: rgb[0]
  g: rgb[1]
  b: rgb[2]


class Blob
  position: new MathExt.Vector()
  velocity: new MathExt.Vector()
  connectingBlobs: new Array()

  constructor: (@colour, @position = (new MathExt.Vector()), @mass = 1) ->
    @uuid = uuid.v4()
    @colour ||= randomColour()

  radius: ->
    (Math.floor(@mass / 3) * 3) + 25

  update: (configuration) ->
    @position.x += @velocity.x
    @position.y += @velocity.y

    @position.x = Math.round(@position.x)
    @position.y = Math.round(@position.y)

    @velocity.x /= configuration.speedDecayPerTick
    @velocity.y /= configuration.speedDecayPerTick

    @

module.exports = Blob

