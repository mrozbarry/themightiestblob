
expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'distanceBetweenBlobs', ->
    it 'accurately calculates the distance between two blobs', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      a = engine.addBlob(blobs, 'foo', [0, 0], 10)
      b = engine.addBlob(blobs, 'foo', [999, 0], 10)
      expect(engine.distanceBetweenBlobs(a, b)).to.equal(999)
