
_ = require('lodash')

module.exports =
  clamp: (value, min, max) ->
    Math.min(
      Math.max(value, min)
      max
    )

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


