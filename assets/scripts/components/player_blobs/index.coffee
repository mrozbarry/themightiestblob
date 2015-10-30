require('./styles/index.css')

{ g, circle, text } = React.DOM

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
        radius = @radiusOfBlob(blob)
        g
          key: blob.uuid,
          circle
            className: 'player-blob'
            r: radius
            cx: center.x
            cy: center.y
            strokeWidth: '5px'
            style:
              fill: @rgbToCssString(blob.colour, 0.75)
              stroke: @rgbToCssString(blob.colour, 1.0)
          text
            x: center.x
            y: center.y
            textAnchor: 'middle'
            style: {
              fontSize: '16px'
            },
            player.name

          text
            x: center.x
            y: center.y + radius + 20
            textAnchor: 'start'
            style: {
              fontSize: '16px'
            },
            "<#{Math.round(blob.position.x)}, #{Math.round(blob.position.y)}>"

