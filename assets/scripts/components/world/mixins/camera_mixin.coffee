
module.exports =
  getInitialState: ->
    camera:
      position:
        x: 0
        y: 500
      zoom: 1.0
      targetPlayerUuid: null

  svgSize: ->
    x: 1920, y: 1080

  shouldAnimateCamera: false
  animationHandle: null
  lastTimeStamp: null

  componentDidMount: ->
    @shouldAnimateCamera = true
    @setAnimationCallbackHandle()

  componentWillUnmount: ->
    @shouldAnimateCamera = false
    @unsetAnimationCallbackHandle()

  localToScaledPosition: (localPosition, dom) ->
    svgSize = @svgSize()
    domBounds = dom.getBoundingClientRect()
    {
      x: (domBounds.width / svgSize.x) * localPosition.x
      y: (domBounds.height / svgSize.y) * localPosition.y
    }

  localToWorldPosition: (localPosition, dom) ->
    { camera } = @state
    scaled = @localToScaledPosition(localPosition, dom)
    svgSize = @svgSize()
    {
      x: camera.position.x + scaled.x - (svgSize.x / 2)
      y: camera.position.y + scaled.y - (svgSize.y / 2)
    }

  getDelta: (timeStamp) ->
    delta = 0
    if @lastTimeStamp
      delta = timeStamp - @lastTimeStamp
    delta

  getCameraTarget: ->
    gameState = @state.gameState
    @positionOfPlayer(gameState.spectatingUuid || gameState.uuid)

  cameraAnimationCallback: (timeStamp) ->
    { camera } = @state

    delta = @getDelta(timeStamp)
    target = @getCameraTarget()
    svgSize = @svgSize()

    camera.position = @interpolateMotion(camera.position, target, 3000, delta)
    @setState camera: camera

    @setAnimationCallbackHandle()
    @lastTimeStamp = timeStamp

  cameraToSvgTransform: (camera, svgSize) ->
    x = (svgSize.x / 2) - camera.position.x
    y = (svgSize.y / 2) - camera.position.y
    [
      'translate('
      x
      ','
      y
      ')'
    ].join('')

  # ---
  #
  setAnimationCallbackHandle: ->
    if @shouldAnimateCamera
      @animationHandle = requestAnimationFrame(@cameraAnimationCallback)

  unsetAnimationCallbackHandle: ->
    if @animationHandle
      cancelAnimationFrame(@animationHandle)

