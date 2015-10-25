{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:PlayerBlobs'

  rgbToCssString: (rgb, darken = 1.0) ->
    "rgba(#{rgb.r / darken}, #{rgb.g / darken}, #{rgb.b / darken}, 1.0)"

  render: ->
    { player } = @props

    console.log 'PlayerBlobs.player', player


    g className: 'blobs__blobs',
      player.blobs.map (blob) =>
        center = @props.translatePoint(blob.position.x, blob.position.y)
        circle
          key: blob.uuid
          r: blob.radius()
          cx: center.x
          cy: center.y
          strokeWidth: '5px'
          style:
            fill: @rgbToCssString(blob.colour, 1.0)
            stroke: @rgbToCssString(blob.colour, 2.0)

