
Login =   require('./components/login/index')
World =   require('./components/world/index')

TheMightiestBlob = require('../../lib/local_modules/the_mightiest_blob')
game = new TheMightiestBlob()

module.exports = Component.create
  displayName: 'Application'

  getInitialState: ->
    userName: 'demo'
    userId: null
    nextHash: null

  render: ->
    World
      game: game

