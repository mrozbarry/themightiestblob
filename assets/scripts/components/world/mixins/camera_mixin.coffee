module.exports =
  componentDidMount: ->
    @addGameStateCallback('before', @cameraAnimationCallback)

  componentWillUnmount: ->
    @removeGameStateCallback('before', @cameraAnimationCallback)

  cameraAnimationCallback: (delta, state) ->
    target = @getCameraTarget(state)
    svgSize = @svgSize()

    state

  cameraToSvgTransform: (camera, svgSize) ->
    x = (svgSize.x / 2) + camera.position.x
    y = (svgSize.y / 2) + camera.position.y
    [
      'translate('
      x
      ','
      y
      ')'
    ].join('')

