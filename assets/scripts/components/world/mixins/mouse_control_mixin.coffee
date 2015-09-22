
module.exports =
  getInitialState: ->
    mouseControl:
      tracking: false
      world:
        x: 0
        y: 0

  mouseAnimationCallback: null
  lastMouseControlTimeStamp: null

  installOnRef: (reference) ->
    dom = reference.getDOMNode()

    dom.addEventListener('mousemove', @blobMouseTarget, true)
    dom.addEventListener('mouseenter', @enableMouse, true)
    dom.addEventListener('mouseleave', @disableMosue, true)

    @enableMouse(null)

  uninstallFromRef: (reference) ->
    dom = reference.getDOMNode()

    dom.removeEventListener('mousemove', @blobMouseTarget)
    dom.removeEventListener('mouseenter', @enableMouse)
    dom.removeEventListener('mouseleave', @disableMosue)

  blobMouseTarget: (event) ->
    { mouseControl, camera } = @state

    mouse =
      x: event.clientX
      y: event.clientY

    mouseControl.world = @localToWorldPosition(mouse, event.currentTarget)
    @setState mouseControl: mouseControl

  targetBlob: (timeStamp) ->
    { mouseControl } = @state
    delta = 1
    if @lastMouseControlTimeStamp
      delta = @lastMouseControlTimeStamp - timeStamp
      @lastMouseControlTimeStamp = timeStamp
    @moveBlobsOfPlayerTo('some-guid', mouseControl.world, delta)
    console.log 'MouseControlMixin.targetBlob'
    @mouseAnimationCallback = requestAnimationFrame(@targetBlob)

  disableMouse: (event) ->
    @setMouseControlTracking(false)
    if @mouseAnimationCallback
      cancelAnimationFrame(@mouseAnimationCallback)
      @mouseAnimationCallback = null

  enableMouse: (event) ->
    @setMouseControlTracking(true)
    @targetBlob(0)

  setMouseControlTracking: (toggle) ->
    { mouseControl } = @state
    mouseControl.tracking = toggle
    @setState mouseControl: mouseControl

