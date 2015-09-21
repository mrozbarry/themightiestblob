
module.exports =
  interpolateMotion: (currentPosition, targetPosition, arriveInMilliseconds, deltaTime) ->
    xDiff = targetPosition.x - currentPosition.x
    yDiff = targetPosition.y - currentPosition.y

    xMove = (xDiff / arriveInMilliseconds) * deltaTime
    yMove = (yDiff / arriveInMilliseconds) * deltaTime

    currentPosition.x += xMove
    currentPosition.y += yMove

    currentPosition
