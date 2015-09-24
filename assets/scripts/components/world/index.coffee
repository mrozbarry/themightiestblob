require('./styles/index.sass')

uuid = require('uuid')

# WorldMixins = require('./mixins/index')

{ svg, g, circle } = React.DOM

module.exports = Component.create
  displayName: 'Components:World'

  # mixins: WorldMixins
  getInitialState: ->
    camera: new MathExt.Vector()
    uuid: null

  componentDidMount: ->
    { game } = @props
    game.subscribe 'tmb:player:list', @showPlayers

    game.publish 'tmb:player:join', {
      uuid: uuid.v4()
      name: 'Alex'
    }

    game.publish 'tmb:player:join', {
      uuid: uuid.v4()
      name: 'Demo'
    }

    game.runSimulation()

  componentWillUnmount: ->

  showPlayers: (event) ->
    console.debug 'World.showPlayers', event

  render: ->
    { game } = @props

    svg
      className: 'blobs-world'
      ref: 'svgRoot'
      viewBox: "0 0 1920 1080"
      preserveAspectRatio: 'xMidYMid',

      g {},

        React.Children.map @props.children, (child) ->
          React.cloneElement child, _.extend {
            game: game
          }, child.props

