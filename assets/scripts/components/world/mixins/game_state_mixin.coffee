blobId = 1
module.exports =
  randomBlobPosition: ->
    (Math.random() * 20000) - 10000

  randomBlobColour: ->
    hexValues = '0123456789ABCDEF'
    hex = [0...6].map((index) ->
      _.sample(hexValues)
    )
    hex.unshift('#')
    hex.join('')

  randomBlobMass: -> Math.random() * 20 + 5

  createBlob: (playerUuid, position, mass, colour) ->
    {
      uuid: blobId++
      playerUuid: playerUuid
      x: _.get(position, 'x', @randomBlobPosition())
      y: _.get(position, 'y', @randomBlobPosition())
      vx: 0
      vy: 0
      mass: mass || @randomBlobMass()
      color: colour || @randomBlobColour()
    }

  getInitialState: ->
    blobs = new Array()
    blobs.push @createBlob('some-guid', {x: 0, y: 0}, 20, '#ff00ff')
    _.each [0..100], (blobNum) => blobs.push @createBlob()

    gameState:
      uuid: 'some-guid'
      spectatingUuid: null

      players: [
        {uuid: 'some-guid', name: 'Demo'}
      ]

      blobs: blobs

  playerBlobs: (uuid) ->
    { gameState } = @state

    return [] unless gameState && (gameState.players.length > 0)

    player = _.find(gameState.players, uuid: uuid)
    _.select gameState.blobs, (blob) -> blob.playerUuid == player.uuid

  positionOfPlayer: (uuid) ->
    blobs = @playerBlobs(uuid)

    unless blobs.length > 0
      return { x: 0, y: 0 }

    _.reduce blobs, ((centroid, blob) ->
      centroid.x = (centroid.x + blob.x) / 2
      centroid.y = (centroid.y + blob.y) / 2
      centroid
    ), { x: blobs[0].x, y: blobs[0].y }


  moveBlobsOfPlayerTo: (uuid, worldPosition, deltaTime) ->
    { gameState } = @state
    gameState.blobs = _.map gameState.blobs, (blob) =>
      return blob unless blob.playerUuid == uuid
      @moveBlobTowards(blob, worldPosition, deltaTime)
    @setState gameState: gameState


  moveBlobTowards: (blob, target, deltaTime) ->
    xDiff = blob.x - target.x
    yDiff = blob.y - target.y
    dist = Math.sqrt((xDiff * xDiff) + (yDiff * yDiff))
    targetPosition =
      x: ((xDiff / dist) * 100 / blob.mass)
      y: ((yDiff / dist) * 100 / blob.mass)
    nextPosition = @interpolateMotion(blob, targetPosition, 1000, deltaTime)
    blob.x = nextPosition.x
    blob.y = nextPosition.y
    blob



