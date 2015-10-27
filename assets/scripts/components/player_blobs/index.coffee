{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:PlayerBlobs'

  rgbToCssString: (rgb, darken = 1.0) ->
    "rgba(#{rgb.r / darken}, #{rgb.g / darken}, #{rgb.b / darken}, 1.0)"

  radiusOfBlob: (blob) ->
    (Math.floor(blob.mass / 3) * 3) + 10

  render: ->
    { player } = @props

    g className: 'blobs__blobs',
      player.blobs.map (blob) =>
        center = @props.translatePoint(blob.position.x, blob.position.y)
        circle
          key: blob.uuid
          r: @radiusOfBlob(blob)
          cx: center.x
          cy: center.y
          strokeWidth: '5px'
          style:
            fill: @rgbToCssString(blob.colour, 1.0)
            stroke: @rgbToCssString(blob.colour, 2.0)

