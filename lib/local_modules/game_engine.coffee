interpolateMotion = require('../interpolate_motion')
MathExt = require('./math_ext')

class TheMightiestBlob
  @EVENTS =
    PRERENDER: 'tmb:render:before'
    RENDER: 'tmb:render:present'
    POSTRENDER: 'tmb:render:after'

  constructor: (@svgTarget) ->
    @lastTimeStep = null
    @animationFrameHandle = null
    @camera = MathExt.Rect.fromPointWithSize(new MathExt.Vector(0, 0), 1920, 1080)
    @blobs = new Array()
    @players = new Array()
    @inputPlayerUuid = null

  subscribe: (eventName, method) ->
    @eventTarget.addEventListener(eventName, method, true)

  unsubscribe: (eventName, method) ->
    @eventTarget.removeEventListener(eventName, method)

  publish: (eventName, payload) ->
    evt = new CustomEvent eventName,
      detail: payload
    @eventTarget.dispatchEvent(evt)

  runSimulation: ->
    @gameStep(null)

  pauseSimulation: ->
    if @animationFrameHandle
      cancelAnimationFrame(@animationFrameHandle)
    @animationFrameHandle = null

  gameStepDelta: (timeStep) ->
    delta = 0
    delta = timeStep - @lastTimeStep if @lastTimeStep?
    @lastTimeStep = timeStep
    delta

  domToWorldCoordinate: (mouseVector) ->
    svgPoint = @svgTarget.createSVGPoint()
    svgPoint.x = localPosition.x
    svgPoint.y = localPosition.y
    svgPoint.matrixTransform(@svgTarget.getScreenCTM().inverse())

  setMousePosition: (x, y) ->
    @lastMousePosition

  blobSplit: ->
    # TODO

  blobMerge: ->
    # TODO

  createPayload: (customData = {}) ->
    _.extend {
      input:
        setMousePosition: @setMousePosition
        blobSplit: @blobSplit
        blobMerge: @blobMerge
    }, customData

  gameStep: (timeStep) ->
    delta = @gameStepDelta(timeStep)

    @publish TheMightiestBlobLocal.EVENTS.PRERENDER,
      @createPayload()

    @blobs = @simulateEachBlob(@blobs, @players)

    @publish TheMightiestBlobLocal.EVENTS.POSTRENDER,
      @createPayload()

    @animationFrameHandle = requestAnimationFrame(
      @gameStep
    )

  simulatePlayersAndBlobs: (players, blobs) ->
    _.map blobs, (blob) =>
      player = _.find players, uuid: blob.playerUuid
      return blob unless player
      @updateBlob(blob, player)

  updateBlob: (blob, player) ->
    unit = player.target.normal(blob.position)
    blob.position = blob.position.add(
      unit.multiply(1000 / blob.mass)
    )
    blob


