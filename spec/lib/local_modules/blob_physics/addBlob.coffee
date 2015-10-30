expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'addBlob', ->
    it 'succeeds when specifying an ownerId, x, y, and radius', ->
      engine = new BlobPhysicsEngine()
      foo = engine.findOrCreateOwner('foo')
      engine.addBlob('foo', 0, 0, 1)
      expect(foo.blobs).to.have.length(1)

    it 'returns the newly created blob', ->
      engine = new BlobPhysicsEngine()
      foo = engine.findOrCreateOwner('foo')
      newBlob = engine.addBlob('foo', 0, 0, 1)
      expect(foo.blobs[0]).to.equal(newBlob)

    it 'fails when an owner cannot be found or created', ->
      engine = new BlobPhysicsEngine()
      newBlob = engine.addBlob(undefined, 0, 0, 1)
      expect(newBlob).to.not.be.ok()

