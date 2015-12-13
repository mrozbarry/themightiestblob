{ g } = React.DOM

Player = require('./player')

module.exports = Component.create
  displayName: 'Components:Players:Index'

  massOfBlobs: (blobs) ->
    _.reduce blobs, ((totalMass, blob) ->
      return totalMass if blob.mass == Infinity
      totalMass + blob.mass
    ), 0

  collectPlayerBlobStats: (player, blobs, massOfAllBlobs) ->
    ownedBlobs = _.select blobs, ownerId: player.uuid
    ownedMass = @massOfBlobs(ownedBlobs)

    player: player
    totalPercentage: (ownedMass / massOfAllBlobs)
    blobMassPercentages: _.map(ownedBlobs, (blob) -> blob.mass / massOfAllBlobs)

  collectAndSortStats: (players, blobs) ->
    massOfAllBlobs = @massOfBlobs(blobs)
    stats = _.map players, (player) =>
      @collectPlayerBlobStats(player, blobs, massOfAllBlobs)

    _.sortByOrder stats, ['totalPercentage'], ['desc']

  render: ->
    { players, blobs, left, top, width } = @props

    return null unless players.length > 0 && blobs.length > 0

    statistics = @collectAndSortStats(players, blobs)


    g {},
      _.map statistics, (statistic, idx) ->
        Player
          key: statistic.player.uuid
          statistics: statistic
          top: top + (24 * idx)
          left: left
          height: 24
          width: width




