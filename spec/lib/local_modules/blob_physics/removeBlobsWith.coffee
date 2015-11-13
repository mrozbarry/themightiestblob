
expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'removeBlobsWith', ->
    it 'returns 0 when no blobs are removed', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      blobs = engine.removeBlobsWith(blobs, ownerId: 'foo')
      expect(blobs.length).to.equal(0)

    it 'removes all blobs owned by "foo" when all are owned by foo', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      [0...10].forEach (blobNumber) ->
        engine.addBlob(blobs, 'foo', 0, 0, 10)

      blobs = engine.removeBlobsWith(blobs, ownerId: 'foo')
      expect(blobs).to.have.length(0)


    it 'removes only blobs owned by "foo" when some are owned by foo', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()

      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobs, blobOwner, 0, 0, 10)

      blobs = engine.removeBlobsWith(blobs, ownerId: 'foo')
      expect(blobs).to.have.length(3)

    it 'does not mutate .blobs when no attributes are passed', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()

      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobs, blobOwner, 0, 0, 10)

      blobs = engine.removeBlobsWith(blobs, undefined)
      expect(blobs).to.have.length(7)

