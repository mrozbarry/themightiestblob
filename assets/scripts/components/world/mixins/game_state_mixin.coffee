
module.exports =
  randomBlobPosition: ->
    (Math.random() * 2000) - 1000

  randomBlobColour: ->
    hexValues = '0123456789ABCDEF'
    hex = [0...6].map((index) ->
      _.sample(hexValues)
    )
    hex.unshift('#')
    hex.join('')

  randomBlobMass: -> Math.random() * 20

  getInitialState: ->
    gameState:
      uuid: 'some-guid'
      spectatingUuid: null

      players: [
        {uuid: 'some-guid', name: 'Demo'}
      ]

      blobs: [
        {
          uuid: 'some-guid',
          x: 0, y: 200, vx: 0, vy: 0,
          colour: '#ff00ff'
          mass: 25.0
        }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
        { x: @randomBlobPosition(), y: @randomBlobPosition(), vx: 0, vy: 0, colour: @randomBlobColour(), mass: @randomBlobMass() }
      ]

  getGameState: ->
    @state.game

  positionOfPlayer: (uuid) ->
    { gameState } = @state

    unless gameState && (gameState.players.length > 0)
      return { x: 0, y: 0 }

    player = _.find(gameState.players, uuid: uuid)

    blobs = _.select gameState.blobs, (blob) ->
      blob.uuid == player.uuid

    unless blobs.length > 0
      return { x: 0, y: 0 }

    _.reduce blobs, ((centroid, blob) ->
      centroid.x = (centroid.x + blob.x) / 2
      centroid.y = (centroid.y + blob.y) / 2
      centroid
    ), { x: blobs[0].x, y: blobs[0].y }


  installMouseListener: (element) ->
    element.addEventListener 'mousemove', @handleMouseMove

  uninstallMouseListener: (element) ->
    element.removeEventListener 'mousemove', @handleMouseMove

  handleMouseMove: (e) ->

  componentWillMount: ->
    # @socket = new Websocket("ws://#{window.location.host}")
    # @socket.onmessage = @socketMessage
    # @socket.onopen = @socketConnect
    # @socket.onclose = @socketDisconnect

  componentWillUnmount: ->
    # @leaveGame()
    # @socket.close()
    # delete @socket
    # @socket = null

  socketMessage: (event) ->

  socketConnect: ->

  socketDisconnect: ->

  socketSend: (channel, message) ->

  joinGame: ->

  leaveGame: ->



