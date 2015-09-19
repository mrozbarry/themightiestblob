
BlobIntegrationModule = require('../../../server/modules/blob_integration_module.coffee')
expect = require('expect.js')

describe 'BlobIntegrationModule', ->
  context 'advanceBlob', ->
    blob = null

    beforeEach ->
      blob =
        x: 0
        y: 0
        vx: 1
        vy: 0

    it 'increases the blob x value by one with a delta time of 1.0', ->
      nextBlob = BlobIntegrationModule.advanceBlob(blob, 1.0)
      expect(nextBlob.x).to.equal(1)

    it 'ignores the blob y value with a delta time of 1.0', ->
      nextBlob = BlobIntegrationModule.advanceBlob(blob, 1.0)
      expect(nextBlob.y).to.equal(0)

    it 'increases the blob x value by one and decreases y by one', ->
      blob.vy = -1
      nextBlob = BlobIntegrationModule.advanceBlob(blob, 1.0)
      expect(nextBlob.x).to.equal(1)
      expect(nextBlob.y).to.equal(-1)

  context 'advancePlayer', ->
    player = null

    beforeEach ->
      player =
        id: 'foo-bar'
        blobs: [
          {x: 0, y: 0, vx: 1, vy: 1}
          {x: 2, y: 1, vx: 1, vy: 1}
        ]

    it 'advances all blobs properly', ->
      nextPlayer = BlobIntegrationModule.advancePlayer(player, 1)
      expect(nextPlayer.blobs[0]).to.eql({x: 1, y: 1, vx: 1, vy: 1})
      expect(nextPlayer.blobs[1]).to.eql({x: 3, y: 2, vx: 1, vy: 1})

  context 'advanceGame', ->
    game = null

    beforeEach ->
      game =
        lastTick: 0
        players: [
          {
            id: 'foo-bar'
            blobs: [
              {x: 0, y: 0, vx: 1, vy: 1}
              {x: 2, y: 1, vx: 1, vy: 1}
            ]
          }
        ]

    it 'advances all players by the difference in the last advanceGame call', ->
      nextGame = BlobIntegrationModule.advanceGame(game, 1)
      expect(nextGame.players[0].blobs[0]).to.eql({x: 1, y: 1, vx: 1, vy: 1})
      expect(nextGame.players[0].blobs[1]).to.eql({x: 3, y: 2, vx: 1, vy: 1})


