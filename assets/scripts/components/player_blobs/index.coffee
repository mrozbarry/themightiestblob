{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:PlayerBlobs'

  rgbToCssString: (rgb, alpha) ->
    "rgba(#{rgb.r}, #{rgb.g}, #{rgb.b}, #{alpha})"

  radiusOfBlob: (blob) ->
    (Math.floor(blob.mass / 3) * 3) + 25

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
            fill: @rgbToCssString(blob.colour, 0.75)
            stroke: @rgbToCssString(blob.colour, 1.0)

