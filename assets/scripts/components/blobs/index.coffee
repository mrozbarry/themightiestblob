{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:Blobs'

  render: ->
    { game } = @props

    g className: 'blobs__blobs',
      game.blobs.map (blob, idx) ->
        circle
          key: idx
          cx: blob.x
          cy: blob.y
          r: blob.mass
          strokeWidth: '5px'
          style:
            fill: blob.colour
            stroke: '#ff0000'

