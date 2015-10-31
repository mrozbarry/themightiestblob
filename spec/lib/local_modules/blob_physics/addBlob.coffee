expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'addBlob', ->
    it 'succeeds when specifying an ownerId, x, y, and radius', ->
      engine = new BlobPhysicsEngine()
      engine.addBlob('foo', 0, 0, 1)
      expect(engine.blobs).to.have.length(1)

    it 'returns the newly created blob', ->
      engine = new BlobPhysicsEngine()
      newBlob = engine.addBlob('foo', 0, 0, 1)
      expect(engine.blobs[0]).to.equal(newBlob)

    it 'fails when an owner cannot be found or created', ->
      engine = new BlobPhysicsEngine()
      newBlob = engine.addBlob(undefined, 0, 0, 1)
      expect(newBlob).to.not.be.ok()

    it 'does not create a blob without an owner', ->
      engine = new BlobPhysicsEngine()
      engine.addBlob(undefined, 0, 0, 1)
      expect(engine.blobs).to.have.length(0)

