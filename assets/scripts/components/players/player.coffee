{ g, rect, text } = React.DOM

module.exports = Component.create
  displayName: 'Components:Players:Player'

  render: ->
    {
      statistics
      top
      left
      width
      height
    } = @props

    graphLeft = left + 1
    graphTop = top + 1
    graphWidth = width - 2
    graphHeight = height - 2

    g {},
      rect
        x: left
        y: top
        width: width
        height: height
        stroke: '#fff'
        fill: 'rgba(0, 0, 0, 0.2)'

      rect
        x: graphLeft
        y: graphTop
        width: graphWidth * statistics.totalPercentage
        height: graphHeight
        stroke: '#fff'
        fill: statistics.player.colour
        fillOpacity: 0.5

      text
        x: graphLeft
        y: graphTop + graphHeight - 3
        textAnchor: 'start',
        "#{statistics.player.name}"
