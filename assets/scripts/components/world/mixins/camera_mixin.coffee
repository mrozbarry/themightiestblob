interpolateMotion = require('../../../lib/interpolate_motion')
module.exports =
  componentDidMount: ->
    @addGameStateCallback('before', @cameraAnimationCallback)

  componentWillUnmount: ->
    @removeGameStateCallback('before', @cameraAnimationCallback)

  cameraAnimationCallback: (delta, state) ->
    target = @getCameraTarget(state)
    svgSize = @svgSize()

    state.camera.position = interpolateMotion(state.camera.position, target, 1000, delta)

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

