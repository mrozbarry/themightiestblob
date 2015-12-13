sillyname = require('sillyname')

{ div, input, button, h1, h2 } = React.DOM

module.exports = Component.create
  displayName: 'Components:JoinModal'

  randomName: (e) ->
    e.preventDefault()

    @refs.name.value = sillyname()

  joinGame: (e) ->
    e.preventDefault()

    name = @refs.name.value
    unless name
      alert 'Cannot join without a name'
      return

    mass = parseInt(@refs.mass.value)
    unless _.contains [1..300], mass
      alert 'Cannot join with mass outside 1-300'
      return

    @props.joinGame(@refs.name.value, @refs.mass.value)

  render: ->
    { previous } = @props



    div className: 'join-modal',
      h1 className: 'join-modal__title', 'Get Ready To Blob!'
      div className: 'join-modal__name',
        h2 className: 'join-modal__name-prompt',
          'Your Name'
        input
          className: 'join-modal__name-input'
          ref: 'name'
          type: 'text'
          placeholder: 'Nickname'
          defaultValue: previous.name

        button
          onClick: @randomName,
          'Randomize Name'

      div {},
        h2 {}, 'Start Mass'
        input
          type: 'number'
          min: 10
          max: 100
          defaultValue: previous.mass
          ref: 'mass'

      div {},
        button
          onClick: @joinGame,

          'Join Game'
