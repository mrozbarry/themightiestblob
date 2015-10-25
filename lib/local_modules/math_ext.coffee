
_ = require('lodash')

class Vector
  constructor: (@x = 0, @y = 0) ->

  add: (other) ->
    new Vector(@x + other.x, @y + other.y)

  subtract: (other) ->
    new Vector(@x - other.x, @y - other.y)

  multiply: (number) ->
    new Vector(@x * number, @y * number)

  divide: (number) ->
    new Vector(@x / number, @y / number)

  distance: (other) ->
    diff = @subtract(other)
    Math.sqrt((diff.x * diff.x) + (diff.y * diff.y))

  normalize: (other) ->
    @subtract(other).divide(@distance(other))

class Rect
  @fromPointWithSize: (center, width, height) ->
    topLeft = center.subtract(new Vector(width/2, height/2))
    bottomRight = center.add(new Vector(width/2, height/2))
    new Rect(topLeft, bottomRight)

  constructor: (topLeft, bottomRight) ->
    lowX = Math.min(topLeft.x, bottomRight.x)
    highX = Math.max(topLeft.x, bottomRight.x)

    lowY = Math.min(topLeft.y, bottomRight.y)
    highY = Math.max(topLeft.y, bottomRight.y)

    @topLeft = new Vector(lowX, lowY)
    @bottomRight = new Vector(highX, highY)

  width: ->
    Math.abs(@bottomRight.x - @topLeft.x)

  height: ->
    Math.abs(@bottomRight.y - @topLeft.y)

  center: ->
    topLeft.add(bottomRight).divide(2)

  translate: (topLeft) ->
    diff = @topLeft.subtract(topLeft)
    @topLeft = topLeft
    @bottomRight = topLeft.add(diff)

  translateRelative: (offsetVector) ->
    @topLeft.add(offsetVector)
    @bottomRight.add(offsetVector)

  containsVector: (vec) ->
    xInRange = @topLeft.x < vec.x < @bottomRight.x
    yInRange = @topLeft.y < vec.y < @bottomRight.y

    xInRange && yInRange

  containsRect: (rect) ->
    containsTL = @containsVector(rect.topLeft)
    containsBR = @containsVector(rect.bottomRight)
    containTL && containsBR

MathExt =
  clamp: (value, min, max) ->
    Math.min(
      Math.max(value, min)
      max
    )

  Vector: Vector
  Rect: Rect

  vectorBetween: (vector1, vector2) ->
    verticalDifference = vector2.y - vector1.y
    horizontalDifference = vector2.x - vector1.x

    magnitude = Math.sqrt((verticalDifference * verticalDifference) + (horizontalDifference * horizontalDifference))
    angle = Math.atan (verticalDifference / horizontalDifference)

    {
      x: _.round(Math.cos(angle), 1)
      y: _.round(Math.sin(angle), 1)
      magnitude: magnitude
    }


module.exports = MathExt

