
expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'removeBlobsWith', ->
    it 'returns 0 when no blobs are removed', ->
      engine = new BlobPhysicsEngine()
      numberRemoved = engine.removeBlobsWith(ownerId: 'foo')
      expect(numberRemoved).to.equal(0)

    it 'removes all blobs owned by "foo"', ->
      engine = new BlobPhysicsEngine()
      [0...10].forEach (blobNumber) ->
        engine.addBlob('foo', 0, 0, 10)

      engine.removeBlobsWith(ownerId: 'foo')
      expect(engine.blobs).to.have.length(0)


    it 'removes only blobs owned by "foo"', ->
      engine = new BlobPhysicsEngine()
      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobOwner, 0, 0, 10)

      engine.removeBlobsWith(ownerId: 'foo')
      expect(engine.blobs).to.have.length(3)

    it '0 when an empty set of attributes is passed', ->
      engine = new BlobPhysicsEngine()

      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobOwner, 0, 0, 10)

      numberRemoved = engine.removeBlobsWith(undefined)
      expect(numberRemoved).to.equal(0)

    it 'does not mutate .blobs when no attributes are passed', ->
      engine = new BlobPhysicsEngine()

      ['foo', 'foo', 'foo', 'bar', 'foo', 'bar', 'baz'].forEach (blobOwner) ->
        engine.addBlob(blobOwner, 0, 0, 10)

      engine.removeBlobsWith(undefined)
      expect(engine.blobs).to.have.length(7)

