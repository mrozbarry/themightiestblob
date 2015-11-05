{ g, line } = React.DOM

module.exports = Component.create
  displayName: 'Component:Grid'

  render: ->
    { xMin, yMin, xMax, yMax, colour, spacing } = @props

    xSteps = (xMax - xMin) / spacing
    ySteps = (yMax - yMin) / spacing

    g {},
      _.map [0..xSteps], (step) =>
        x = xMin + (step * spacing)
        line
          key: "x-#{step}"
          x1: x
          y1: yMin
          x2: x
          y2: yMax
          stroke: colour

      _.map [0..ySteps], (step) =>
        y = yMin + (step * spacing)
        line
          key: "y-#{step}"
          x1: xMin
          y1: y
          x2: xMax
          y2: y
          stroke: colour



