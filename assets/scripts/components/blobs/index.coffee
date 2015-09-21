{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:Blobs'

  render: ->
    { blobs } = @props

    g className: 'blobs__blobs',
      blobs.map (blob) ->
        circle
          cx: blob.x
          cy: blob.y
          r: blob.mass
          strokeWidth: '5px'
          style:
            fill: blob.colour
            stroke: '#ff0000'

