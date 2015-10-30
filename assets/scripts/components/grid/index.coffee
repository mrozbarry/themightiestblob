{ g, line } = React.DOM

module.exports = Component.create
  displayName: 'Component:Grid'

  render: ->
    { xMin, yMin, xMax, yMax, colour, spacing } = @props

    xSteps = (xMax - xMin) / spacing
    ySteps = (yMax - yMin) / spacing

    g {},
      _.map [0..xSteps], (step) =>
        x = @props.translateAxis(xMin + (step * spacing), 'x')
        line
          key: "x-#{step}"
          x1: x
          y1: @props.translateAxis(yMin, 'y')
          x2: x
          y2: @props.translateAxis(yMax, 'y')
          stroke: colour

      _.map [0..ySteps], (step) =>
        y = @props.translateAxis(yMin + (step * spacing), 'y')
        line
          key: "y-#{step}"
          x1: @props.translateAxis(xMin, 'x')
          y1: y
          x2: @props.translateAxis(xMax, 'x')
          y2: y
          stroke: colour



