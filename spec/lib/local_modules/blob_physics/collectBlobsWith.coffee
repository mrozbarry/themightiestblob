
expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'collectBlobsWith', ->
    it 'returns an empty array when there are no blobs', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      collected = engine.collectBlobsWith(blobs, ownerId: 'foo')
      expect(collected).to.have.length(0)

    it 'returns a list of blobs owned by "foo"', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      [0...10].forEach (blobNumber) ->
        engine.addBlob(blobs, 'foo', 0, 0, 10)

      collected = engine.collectBlobsWith(blobs, ownerId: 'foo')
      expect(collected).to.have.length(10)


    it 'filters out blobs now owned by "foo"', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()
      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobs, blobOwner, 0, 0, 10)

      collected = engine.collectBlobsWith(blobs, ownerId: 'foo')
      expect(collected).to.have.length(4)

    it 'does not filter when an empty set of attributes is passed', ->
      engine = new BlobPhysicsEngine()
      blobs = new Array()

      collected = engine.collectBlobsWith(blobs, undefined)
      expect(collected).to.have.length(0)


