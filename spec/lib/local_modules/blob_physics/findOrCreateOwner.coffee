expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'findOrCreateOwner', ->
    it 'adds an owner when one does not exist', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner('foo')
      expect(engine.owners.length).to.equal(1)

    it 'returns a new owner when one does not exist', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner('foo')
      expect(newOwner.id).to.equal('foo')
      expect(newOwner.blobs).to.have.length(0)

    it 'should not add another owner when one with the same id already exists', ->
      engine = new BlobPhysicsEngine()
      originalOwner = engine.findOrCreateOwner('foo')
      newOwner = engine.findOrCreateOwner('foo')
      expect(engine.owners).to.have.length(1)

    it 'returns an owner when one already exists', ->
      engine = new BlobPhysicsEngine()
      originalOwner = engine.findOrCreateOwner('foo')
      newOwner = engine.findOrCreateOwner('foo')
      expect(newOwner).to.equal(originalOwner)

    it 'returns false when ownerId is null', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner(null)
      expect(newOwner).to.not.be.ok()

    it 'rejects when ownerId is undefined', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner(undefined)
      expect(newOwner).to.not.be.ok()

    it 'does not reject when ownerId is 0', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner(0)
      expect(newOwner).to.be.ok()

    it 'does not reject when ownerId is ""', ->
      engine = new BlobPhysicsEngine()
      newOwner = engine.findOrCreateOwner("")
      expect(newOwner).to.be.ok()

    it 'adds n owners with uniq ids', ->
      engine = new BlobPhysicsEngine()
      [0...10].forEach (ownerId) ->
        engine.findOrCreateOwner(ownerId)
      expect(engine.owners).to.have.length(10)
