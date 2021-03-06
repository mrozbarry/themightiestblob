expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'checkCollision', ->
    it 'returns true if two blobs are just touching', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      a = engine.addBlob(blobs, 'foo', [0, 0], 10)
      b = engine.addBlob(blobs, 'foo', [19, 0], 10)
      expect(engine.checkCollision(a, b)).to.be.ok()

    it 'returns true if two blobs are just overlapping', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      a = engine.addBlob(blobs, 'foo', [0, 0], 10)
      b = engine.addBlob(blobs, 'foo', [10, 0], 10)
      expect(engine.checkCollision(a, b)).to.be.ok()

    it 'returns false if two blobs are not touching', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      a = engine.addBlob(blobs, 'foo', [0, 0], 10)
      b = engine.addBlob(blobs, 'foo', [20, 0], 10)
      expect(engine.checkCollision(a, b)).to.not.be.ok()

