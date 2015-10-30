MathExt = require('./math_ext')
uuid = require('uuid')
_ = require('lodash')

randomColour = ->
  rgb = _.sample [0...256], 3
  r: rgb[0]
  g: rgb[1]
  b: rgb[2]


class Blob
  constructor: (@colour, @position = (new MathExt.Vector()), @mass = 1) ->
    @uuid = uuid.v4()
    @colour ||= randomColour()
    @position = new MathExt.Vector()
    @velocity = new MathExt.Vector()

  radius: ->
    (Math.floor(@mass / 3) * 3) + 25

  update: (configuration) ->
    @position.x += @velocity.x
    @position.y += @velocity.y

    @position.x = Math.min(Math.max(0, @position.x), configuration.worldSize)
    @position.y = Math.min(Math.max(0, @position.y), configuration.worldSize)

    if @position.x == 0 || @position.x == configuration.worldSize
      @velocity.x = 0

    if @position.y == 0 || @position.y == configuration.worldSize
      @velocity.y = 0

    speed = (new MathExt.Vector()).distance(@velocity)
    slow = speed * @mass

    @velocity = @velocity.divide(configuration.speedDecayPerTick * slow)

    @

module.exports = Blob

