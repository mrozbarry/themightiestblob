

expect = require('expect.js')
BlobPhysicsEngine = require('../../../../lib/local_modules/blob_physics_engine')

describe 'blob_physics_engine', ->
  context 'distanceBetweenBlobs', ->
    it 'accurately calculates point of collision of two blobs', ->
      engine = new BlobPhysicsEngine()
      a = engine.addBlob('foo', [0, 0], 10)
      b = engine.addBlob('foo', [19, 0], 10)
      collisionPoint = engine.calculateCollisionPoint(a, b)
      expect(collisionPoint.position[0]).to.equal(9.5)
      expect(collisionPoint.position[1]).to.equal(0)
