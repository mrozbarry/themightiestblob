_ = require('lodash')

MAX_SPEED = 20

module.exports =
  advanceGame: (game, timeStamp) ->
    deltaTime = timeStamp - game.lastTick
    game.players = _.map game.players, (player) =>
      @advancePlayer(player, deltaTime)
    game.lastTick = timeStamp
    game

  advancePlayer: (player, deltaTime) ->
    player.blobs = _.map player.blobs, (blob) =>
      @advanceBlob(blob, deltaTime)
    player

  advanceBlob: (blob, deltaTime) ->
    blob.x += (blob.vx * deltaTime)
    blob.y += (blob.vy * deltaTime)
    blob

