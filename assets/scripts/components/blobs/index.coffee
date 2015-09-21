{ g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:Blobs'

  render: ->
    { gameState, camera } = @props
    g className: 'blobs__blobs',
      gameState.blobs.map (blob) ->
        circle
          x: camera.position.x - blob.x
          y: blob.y + camera.position.y
          r: blob.mass
          strokeWidth: '5px'
          style:
            fill: blob.colour
            stroke: '#ff0000'

