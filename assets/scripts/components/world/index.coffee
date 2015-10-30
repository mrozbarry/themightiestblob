require('./styles/index.sass')

MathExt = require('../../../../lib/local_modules/math_ext')

{ svg, rect, g, line } = React.DOM

PlayerBlobs = require('../player_blobs/index')
Grid = require('../grid/index')

module.exports = Component.create
  displayName: 'Components:World'

  resolution: new MathExt.Vector(1920, 1080)

  localMouse: {}
  lastTarget: {}
  isMouseActive: false
  mode: 'play'

  componentDidMount: ->
    addEventListener 'keydown', @handleKeyPress, true

  componentWillUnmount: ->
    removeEventListener 'keydown', @handleKeyPress

  handleMouseMotion: (e) ->
    { gameState, uuid } = @props

    return unless uuid

    dom = @refs.root

    point = dom.createSVGPoint()
    point.x = e.clientX
    point.y = e.clientY
    local = point.matrixTransform(dom.getScreenCTM().inverse())
    @localMouse.x = parseInt(local.x)
    @localMouse.y = parseInt(local.y)
    @isMouseActive = true

  handleMouseLeave: (e) ->
    { gameState, uuid } = @props

    return unless uuid

    me = _.find gameState.players, uuid: uuid
    centroid = @averageBlobPosition(me.blobs)

    @props.setTarget(centroid)
    @isMouseActive = false

  handleKeyPress: (e) ->
    { uuid } = @props

    return unless uuid

    # e.preventDefault()

    console.log 'keyPress', e

    if @mode == 'play'
      if e.keyCode == 32
        @props.setSplit()

  sendTarget: (camera) ->
    world =
      x: camera.x + @localMouse.x
      y: camera.y + @localMouse.y

    same =
      x: (world.x == @lastTarget.x)
      y: (world.y == @lastTarget.y)

    return if same.x && same.y

    @lastTarget = world

    @props.setTarget(world)

  averageBlobPosition: (blobs) ->
    return @resolution.divide(-2) unless blobs.length > 0

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
      offset.x = centroid.x - offset.x
      offset.y = centroid.y - offset.y

    offset

  render: ->
    { gameState, lastGameState, uuid } = @props

    me = _.find gameState.players, uuid: uuid
    offset = @cameraTarget(me)

    @sendTarget(offset) if @isMouseActive

    translateAxis = (value, axis) ->
      unless _.contains ['x', 'y'], axis
        throw new Error('translateAxis expects axis to be "x" or "y"')

      value - offset[axis]

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
      ref: 'root'
      onMouseMove: @handleMouseMotion
      onMouseLeave: @handleMouseLeave,

      rect
        x: 0
        y: 0
        width: @resolution.x
        height: @resolution.y
        className: 'blobs-world__background'

      svg
        x: 0
        y: 0
        width: @resolution.x
        height: @resolution.y,

        g {},

          Grid
            xMin: 0
            yMin: 0
            xMax: gameState.configuration.worldSize
            yMax: gameState.configuration.worldSize
            spacing: 100
            colour: '#00aaaa'
            translateAxis: translateAxis

          gameState.players.map (player) ->
            PlayerBlobs
              key: player.uuid
              player: player
              translatePoint: translatePoint

