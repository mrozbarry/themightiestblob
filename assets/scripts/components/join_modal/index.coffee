sillyname = require('sillyname')

{ div, input, button, h1 } = React.DOM

module.exports = Component.create
  displayName: 'Components:JoinModal'

  randomName: (e) ->
    e.preventDefault()

    @refs.name.value = sillyname()

  joinGame: (e) ->
    e.preventDefault()

    @props.joinGame(@refs.name.value)

  render: ->
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
        input
          type: 'text'
          placeholder: 'Your Blobbed-out Name'
          ref: 'name'

        button
          onClick: @randomName,
          'Randomize Name'

      div {},
        button
          onClick: @joinGame,

          'Join Game'
