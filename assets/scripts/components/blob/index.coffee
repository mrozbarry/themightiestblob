require('./styles/index.css')

{ g, circle, text } = React.DOM

module.exports = Component.create
  displayName: 'Components:Blob'

  render: ->
    { blob, player } = @props

    g className: 'blob',
      circle
        className: 'blob__circle'
        r: blob.radius
        cx: blob.position[0]
        cy: blob.position[1]
        strokeWidth: '5px'
        style:
          fill: '#ff00ff'
          stroke: '#0a0a0a'
      text
        x: blob.position[0]
        y: blob.position[1]
        textAnchor: 'middle'
        style: {
          fontSize: '16px'
        },
        player.name
      text
        x: blob.position[0]
        y: blob.position[1] + 20
        textAnchor: 'middle'
        style: {
          fontSize: '16px'
        },
        blob.mass

      text
        x: blob.position[0]
        y: blob.position[1] + 20 + blob.radius
        textAnchor: 'start'
        style: {
          fontSize: '16px'
        },
        "<#{Math.round(blob.position[0])}, #{Math.round(blob.position[1])}>"

