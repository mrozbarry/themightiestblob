require('./styles/index.sass')

{ svg, rect, g, line } = React.DOM

Blob = require('../blob/index')
Grid = require('../grid/index')

module.exports = Component.create
  displayName: 'Components:World'

  resolution: [1920, 1080]
  camera: [0, 0]
  svgTarget: null
  zoom: 1

  updateCamera: (uuid, blobs) ->
    firstBlob = _.find blobs, ownerId: uuid

    return unless firstBlob?

    @camera = _.map @resolution, (resAxis, idx) ->
      parseInt(resAxis / 2 - firstBlob.position[idx])

  updateTarget: ->
    return unless @svgTarget?

    target = [
      @svgTarget[0] - @camera[0]
      @svgTarget[1] - @camera[1]
    ]
    @props.setTarget(target)

  componentWillReceiveProps: (nextProps) ->
    @updateCamera(nextProps.uuid, nextProps.blobs)

  componentWillUpdate: ->
    @updateTarget()

  handleMouseMotion: (e) ->
    return unless @props.uuid?

    dom = @refs.root

    point = dom.createSVGPoint()
    point.x = e.clientX
    point.y = e.clientY
    local = point.matrixTransform(dom.getScreenCTM().inverse())
    local.x = parseInt(local.x)
    local.y = parseInt(local.y)
    @svgTarget = [local.x, local.y]
    @updateTarget()

  handleMouseLeave: (e) ->
    @svgTarget = null
    @props.setTarget(null)

  handleMouseWheel: (e) ->
    @zoom = Math.min(Math.max(1, e.deltaY), 100)

  render: ->
    { uuid, worldAttrs, players, blobs } = @props

    svg
      className: 'blobs-world'
      viewBox: "0 0 #{@resolution[0]} #{@resolution[1]}",
      preserveAspectRatio: 'xMidYMid'
      ref: 'root'
      onMouseMove: @handleMouseMotion
      onMouseLeave: @handleMouseLeave
      onWheel: @handleMouseWheel,

      rect
        x: 0
        y: 0
        width: @resolution[0]
        height: @resolution[1]
        className: 'blobs-world__background'

      svg
        x: 0
        y: 0
        width: @resolution[0]
        height: @resolution[1],

        g transform: "translate(#{@camera[0]}, #{@camera[1]})",
          g transform: "scale(#{@zoom})",

            Grid
              xMin: worldAttrs.min[0]
              yMin: worldAttrs.min[0]
              xMax: worldAttrs.max[0]
              yMax: worldAttrs.max[1]
              spacing: 100
              colour: '#a0a0a0'

            blobs.map (blob, idx) ->
              owner = _.find players, uuid: blob.ownerId
              Blob
                key: idx
                player: owner
                blob: blob

