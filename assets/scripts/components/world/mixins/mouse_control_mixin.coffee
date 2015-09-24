lastMouseState = {x: 0, y: 0}
domElement = null

module.exports =
  installMouseControlOnRef: (reference) ->
    dom = reference.getDOMNode()

    dom.addEventListener('mousemove', @blobMouseTarget, true)
    dom.addEventListener('mouseenter', @enableMouse, true)
    dom.addEventListener('mouseleave', @disableMosue, true)

    @addGameStateCallback 'before', @targetBlob
    domElement = dom

  uninstallMouseControlFromRef: (reference) ->
    dom = reference.getDOMNode()

    dom.removeEventListener('mousemove', @blobMouseTarget)
    dom.removeEventListener('mouseenter', @enableMouse)
    dom.removeEventListener('mouseleave', @disableMosue)

    @removeGameStateCallback 'before', @targetBlob
    domElement = null

  blobMouseTarget: (event) ->
    mouse =
      x: event.clientX
      y: event.clientY

    console.log 'Mouse:', mouse

    lastMouseState = mouse

  targetBlob: (delta, state) ->
    state.mouseControl.world = @localToWorldPosition(lastMouseState, domElement, state)
    return state unless state.mouseControl.world.x? && state.mouseControl.world.y?
    state = @moveBlobsOfPlayerTo(state, 'some-guid', state.mouseControl.world, delta)
    state

