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
    div
      style: {
        zIndex: 999
        position: 'absolute'
        top: '50%'
        left: '50%'
        width: '300px'
        height: '400px'
        marginLeft: '-150px'
        marginTop: '-200px'
        backgroundColor: 'white'
        border: '1px black solid'
      },
      h1 {}, 'Get Ready To Blob!'
      div {},
        h2 {}, 'Your Name'
        input
          type: 'text'
          placeholder: 'Your Blobbed-out Name'
          defaultValue: previous.name
          ref: 'name'

        button
          onClick: @randomName,
          'Randomize Name'

      div {},
        h2 {}, 'Start Mass'
        input
          type: 'number'
          min: 0
          max: 100
          defaultValue: previous.mass
          ref: 'mass'

      div {},
        button
          onClick: @joinGame,

          'Join Game'
