
module.exports = Component.create
  displayName: 'Application'

  mixins: [RouterMini.RouterMixin]

  getInitialState: ->
    serverKeys: []
    userName: null
    game: null

  routes:
    '/': 'renderLogin'
    '/g/:game': 'renderPlay'

  renderLogin: ->

  renderPlay: ->

  notFound: (path) ->
    console.error 'Application.notFound', path
    @renderLogin()

  render: ->
    @renderCurrentRoute()

