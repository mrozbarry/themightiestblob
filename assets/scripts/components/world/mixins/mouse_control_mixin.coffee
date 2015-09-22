
module.exports =
  getInitialState: ->
    mouseControl:
      tracking: false
      world:
        x: 0
        y: 0

  installOnRef: (reference) ->
    dom = reference.getDOMNode()

    dom.addEventListener('mousemove', @blobMouseTarget, true)
    dom.addEventListener('mouseenter', @enableMouse, true)
    dom.addEventListener('mouseleave', @disableMosue, true)

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
    @moveBlobsOfPlayerTo('some-guid', mouseControl.world, 1000)
    @setState mouseControl: mouseControl

  disableMouse: (event) ->
    @setMouseControlTracking(false)

  enableMouse: (event) ->
    @setMouseControlTracking(true)

  setMouseControlTracking: (toggle) ->
    { mouseControl } = @state
    mouseControl.tracking = toggle
    @setState mouseControl: mouseControl

