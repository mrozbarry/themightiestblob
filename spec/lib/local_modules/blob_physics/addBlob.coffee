expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'addBlob', ->
    it 'succeeds when specifying an ownerId, x, y, and radius', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      engine.addBlob(blobs, 'foo', [0, 0], 1)
      expect(blobs).to.have.length(1)

    it 'returns the newly created blob', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      newBlob = engine.addBlob(blobs, 'foo', [0, 0], 1)
      expect(blobs[0]).to.equal(newBlob)

    it 'allows a null owner', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      engine.addBlob(blobs, null, [0, 0], 1)
      expect(blobs).to.have.length(1)

