require('./styles/index.sass')

WorldMixins = require('./mixins/index')

{ svg, g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:World'

  mixins: WorldMixins

  componentDidMount: ->
    setInterval (=>
      { gameState } = @state
      gameState.blobs[0].x += 5
      gameState.blobs[0].y += 0
      console.debug gameState.blobs[0]
      @setState gameState: gameState
    ), 100

  render: ->
    { gameState, camera } = @state

    svgSize = @svgSize()

    svg
      className: 'blobs-world'
      viewBox: "0 0 #{svgSize.x} #{svgSize.y}"
      preserveAspectRatio: 'xMidYMid',

      React.Children.map @props.children, (child) ->
        React.cloneElement child, _.extend {
          gameState: gameState
          camera: camera
        }, child.props

