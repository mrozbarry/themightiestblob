require('./styles/index.sass')

MathExt = require('../../../../lib/local_modules/math_ext')

{ svg, rect, g, line } = React.DOM

PlayerBlobs = require('../player_blobs/index')

module.exports = Component.create
  displayName: 'Components:World'

  resolution: new MathExt.Vector(1920, 1080)

  handleMouseMotion: (e) ->
    { gameState, uuid } = @props

    console.log 'handleMouseMotion', @props

    return unless uuid

    boundingBox = e.target.getBoundingClientRect()
    console.debug 

    local =
      x: (e.clientX / boundingBox.width) * @resolution.x
      y: (e.clientY / boundingBox.height) * @resolution.y

    me = _.find gameState.players, uuid: uuid
    camera = @cameraTarget(me)

    world =
      x: camera.x + local.x
      y: camera.y + local.y

    @props.setTarget(world)

  handleMouseLeave: (e) ->
    { gameState, uuid } = @props

    console.log 'handleMouseLeave', @props

    return unless uuid

    me = _.find gameState.players, uuid: uuid
    centroid = @averageBlobPosition(me.blobs)

    @props.setTarget(centroid)

  averageBlobPosition: (blobs) ->
    return new MathExt.Vector() unless blobs.length > 0
    average = blobs[0].position
    _.reduce blobs, ((centroid, blob) ->
      centroid.x = (centroid.x + blob.position.x) / 2
      centroid.y = (centroid.y + blob.position.y) / 2
      centroid
    ), average

  cameraTarget: (player) ->
    { gameState, uuid } = @props

    offset =
      x: @resolution.x / 2
      y: @resolution.y / 2

    if player
      centroid = @averageBlobPosition(player.blobs)
      offset.x -= centroid.x
      offset.y -= centroid.y

    offset

  render: ->
    { gameState, uuid } = @props

    me = _.find gameState.players, uuid: uuid
    offset = @cameraTarget(me)

    translateAxis = (value, axis) ->
      unless _.contains ['x', 'y'], axis
        throw new Error('translateAxis expects axis to be "x" or "y"')

      value + offset[axis]

    translatePoint = (x, y) ->
      x: translateAxis(x, 'x')
      y: translateAxis(y, 'y')

    translateLine = (x1, y1, x2, y2) ->
      p1 = translatePoint(x1, y1)
      p2 = translatePoint(x2, y2)
      x1: p1.x
      y1: p1.y
      x2: p2.x
      y2: p2.y

    svg
      className: 'blobs-world'
      viewBox: "0 0 #{@resolution.x} #{@resolution.y}",
      preserveAspectRatio: 'xMidYMid'
      ref: 'root',

      rect
        x: 0
        y: 0
        width: @resolution.x
        height: @resolution.y
        className: 'blobs-world__background'
        onMouseMove: @handleMouseMotion
        onMouseLeave: @handleMouseLeave

      svg
        x: 0
        y: 0
        width: @resolution.x
        height: @resolution.y,

        g {},
          # transform: "translate(#{translation.x}, #{translation.y})",

          line _.extend(
            stroke: '#ff00ff',
            translateLine(-9999, 0, 9999, 0)
          )

          line _.extend(
            stroke: '#ff00ff',
            translateLine(0, -9999, 0, 9999)
          )

          gameState.players.map (player) ->
            PlayerBlobs
              key: player.uuid
              player: player
              translatePoint: translatePoint

