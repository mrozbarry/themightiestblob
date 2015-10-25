require('./styles/index.sass')

Player = require('../../../../lib/local_modules/player')
Blob = require('../../../../lib/local_modules/blob')

{ svg, rect, g, line } = React.DOM

PlayerBlobs = require('../player_blobs/index')

module.exports = Component.create
  displayName: 'Components:World'

  resolution: new MathExt.Vector(1920, 1080)

  # mixins: WorldMixins
  getInitialState: ->
    players: new Array()

  setUpWorld: (game) ->
    world = new Player('World')
    world.uuid = null

    _.each [0...50], (blobNumber) ->
      x = Math.random() * (3000 * 2) - 1500
      y = Math.random() * (3000 * 2) - 1500
      world.addBlob new MathExt.Vector(x, y), 0.5

    game.addPlayer world

    game

  componentDidMount: ->
    { game } = @props
    me = new Player('Demo')
    me.addBlob(new MathExt.Vector(), 100)

    game.addPlayer me

    # game = @setUpWorld(game)

    game.on 'game:update', @gameStateUpdate

    @setState { uuid: me.uuid }

    @refs.root.addEventListener 'mousemove', @handleMouseMotion, true

  gameStateUpdate: (gameState) ->

    @setState {
      players: gameState.players
    }

  handleMouseMotion: (e) ->
    root = @refs.root
    boundingBox = root.getBoundingClientRect()
    console.log 'handleMouseMotion.boundingBox', boundingBox.left, boundingBox.top, boundingBox.width, boundingBox.height
    console.debug '                         (', [e.clientX, e.clientY],')'

    # p = renderer.createSVGPoint()
    # p.x = e.clientX
    # p.y = e.clientY
    # blobTarget = p.matrixTransform(
    #   renderer.getScreenCTM().inverse()
    # )
    # vec = new MathExt.Vector(blobTarget.x, blobTarget.y)
    # offset = new MathExt.Vector(@resolution.x / 2, @resolution.y / 2)
    # # console.debug 'World.handleMouseMotion', blobTarget.x, blobTarget.y
    # @props.game.setPlayerTarget(@state.uuid, vec.add(offset))

  myBlobs: (playerUuid, allBlobs) ->
    _.select allBlobs, (blob) ->
      blob.playerUuid == playerUuid

  averageBlobPosition: (blobs) ->
    return new MathExt.Vector() unless blobs.length > 0
    average = blobs[0].position
    _.reduce blobs, ((centeroid, blob) ->
      centeroid.add(blob.position).divide(2)
    ), average

  render: ->
    { uuid, players } = @state

    offset =
      x: @resolution.x / 2
      y: @resolution.y / 2

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

      svg
        ref: 'renderer'
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

          players.map (player) ->
            PlayerBlobs
              key: player.uuid
              player: player
              translatePoint: translatePoint

