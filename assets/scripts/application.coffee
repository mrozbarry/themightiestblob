
Login =   require('./components/login/index')
World =   require('./components/world/index')
Blobs =   require('./components/blobs/index')

TheMightiestBlob = require('../../lib/local_modules/game_engine')
game = new TheMightiestBlob()

module.exports = Component.create
  displayName: 'Application'

  mixins: [RouterMini.RouterMixin]

  getInitialState: ->
    userName: 'demo'

  routes:
    '/': 'renderLogin'
    '/w/:world': 'renderWorld'

  isAbleToPlay: ->
    { userName } = @state
    !!userName

  renderLogin: ->
    @renderWorld('demo')

  renderWorld: (worldKey) ->
    unless @isAbleToPlay()
      return @renderLogin()

    World
      game: game
      worldKey: worldKey,
      Blobs {}

  notFound: (path) ->
    console.error 'Application.notFound', path
    @renderLogin()

  render: ->
    React.DOM.div {},
      @renderCurrentRoute()

