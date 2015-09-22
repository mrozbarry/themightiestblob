require('./styles/index.sass')

WorldMixins = require('./mixins/index')

{ svg, g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:World'

  mixins: WorldMixins

  componentDidMount: ->
    @installOnRef(@refs.svgRoot)

  componentWillUnmount: ->
    @uninstallFromRef(@refs.svgRoot)

  render: ->
    { gameState, camera } = @state

    svgSize = @svgSize()

    svg
      className: 'blobs-world'
      ref: 'svgRoot'
      viewBox: "0 0 #{svgSize.x} #{svgSize.y}"
      preserveAspectRatio: 'xMidYMid',

      g
        transform: @cameraToSvgTransform(camera, svgSize),

        React.Children.map @props.children, (child) ->
          React.cloneElement child, _.extend {
            gameState: gameState
            blobs: gameState.blobs
          }, child.props

