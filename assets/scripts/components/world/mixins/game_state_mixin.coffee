blobId = 1
interpolateMotion = require('../../../lib/interpolate_motion')
module.exports =
  randomBlobPosition: ->
    (Math.random() * 2000) - 1000

  randomBlobColour: ->
    hexValues = '0123456789ABCDEF'
    hex = [0...6].map((index) ->
      _.sample(hexValues)
    )
    hex.unshift('#')
    hex.join('')

  randomBlobMass: -> Math.random() * 20 + 5

  createBlob: (playerUuid, position, mass, colour) ->
    position = position || { x: @randomBlobPosition(), y: @randomBlobPosition() }
    {
      uuid: blobId++
      playerUuid: playerUuid
      x: position.x
      y: position.y
      vx: 0
      vy: 0
      mass: mass || @randomBlobMass()
      colour: colour || @randomBlobColour()
    }

  getInitialState: ->
    blobs = new Array()
    blobs.push @createBlob('some-guid', {x: 0, y: 0}, 20, '#ffffff')
    _.each [0..100], (blobNum) => blobs.push @createBlob()

    gameState:
      uuid: 'some-guid'

      players: [
        {uuid: 'some-guid', name: 'Demo'}
      ]

      blobs: blobs
    camera:
      position:
        x: 100
        y: 100
      zoom: 1.0
      targetPlayerUuid: 'some-guid'
    mouseControl:
      world:
        x: 0
        y: 0

  gameStateAnimationHandle: null
  gameStateLastTimeStamp: null
  gameStateCallbacks:
    before: new Array()
    render: new Array()
    after: new Array()

  addGameStateCallback: (action, callback) ->
    unless _.contains ['before', 'render', 'after'], action
      throw new Error("GameStateMixin.addGameStateCallback: cannot hook callback onto action #{action}")

    @gameStateCallbacks[action].push callback

  removeGameStateCallback: (action, callback) ->
    unless _.contains ['before', 'render', 'after'], action
      throw new Error("GameStateMixin.removeGameStateCallback: cannot hook callback onto action #{action}")

    _.pull @gameStateCallbacks[action], callback

  runGame: (toggle) ->
    if toggle
      @simulationStep(null)
    else
      if @gameStateAnimationHandle
        cancelAnimationFrame(@gameStateAnimationHandle)
      @gameStateAnimationHandle = null


  simulationStep: (timeStamp) ->
    delta = 0
    if @gameStateLastTimeStamp
      delta = timeStamp - @gameStateLastTimeStamp
    @gameStateLastTimeStamp = timeStamp

    state = @state

    @runCallbacksFor 'before', delta, state
    @runCallbacksFor 'render', delta, state
    @runCallbacksFor 'after', delta, state

    @setState state, =>
      @gameStateAnimationHandle = requestAnimationFrame(@simulationStep)

  runCallbacksFor: (action, delta, state) ->
    # console.groupCollapsed action
    # console.log 'before.state', _.clone(state)
    _.each @gameStateCallbacks[action], (callback) -> state = callback(delta, state)
    # console.debug 'after.state', _.clone(state)
    # console.groupEnd()
    state


  playerBlobs: (uuid, state) ->
    { gameState } = state

    return [] unless gameState && (gameState.players.length > 0)

    player = _.find(gameState.players, uuid: uuid)
    _.select gameState.blobs, (blob) -> blob.playerUuid == player.uuid

  positionOfPlayer: (uuid, state) ->
    blobs = @playerBlobs(uuid, state)

    unless blobs.length > 0
      return { x: 0, y: 0 }

    _.reduce blobs, ((centroid, blob) ->
      centroid.x = (centroid.x + blob.x) / 2
      centroid.y = (centroid.y + blob.y) / 2
      centroid
    ), { x: blobs[0].x, y: blobs[0].y }


  moveBlobsOfPlayerTo: (state, uuid, worldPosition, deltaTime) ->
    unless worldPosition.x? && worldPosition.y?
      return

    state.gameState.blobs = _.map state.gameState.blobs, (blob) =>
      return blob unless blob.playerUuid == uuid
      @moveBlobTowards(blob, worldPosition, deltaTime)

    state

  moveBlobTowards: (blob, target, deltaTime) ->
    xDiff = target.x - blob.x
    yDiff = target.y - blob.y
    dist = Math.sqrt((xDiff * xDiff) + (yDiff * yDiff))
    targetPosition =
      x: ((xDiff / dist) * 1000 / blob.mass)
      y: ((yDiff / dist) * 1000 / blob.mass)
    nextPosition = interpolateMotion(blob, targetPosition, 1000, deltaTime)
    blob.x = nextPosition.x
    blob.y = nextPosition.y
    # debugger if deltaTime > 0
    blob

  svgSize: ->
    x: 1920, y: 1080

  localToScaledPosition: (localPosition, dom) ->
    svgPoint = dom.createSVGPoint()
    svgPoint.x = localPosition.x
    svgPoint.y = localPosition.y
    svgPoint.matrixTransform(dom.getScreenCTM().inverse())

  localToWorldPosition: (localPosition, dom, state) ->
    { camera } = state
    scaled = @localToScaledPosition(localPosition, dom)
    console.log 'GameStateMixin.localToWorldPosition.scaled:', scaled
    svgSize = @svgSize()
    {
      x: camera.position.x + scaled.x - (svgSize.x / 2)
      y: camera.position.y + scaled.y - (svgSize.y / 2)
    }

  getCameraTarget: (state) ->
    { gameState, camera } = state

    ownerUuid = gameState.uuid || camera.targetPlayerUuid
    @positionOfPlayer(ownerUuid, state)


