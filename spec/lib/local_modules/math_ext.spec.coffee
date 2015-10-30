
MathExt = require('../../../lib/local_modules/math_ext')
expect = require('expect.js')

describe 'MathExt', ->
  context 'clamp', ->
    it 'does not change values with range', ->
      expect(MathExt.clamp(5, 0, 10)).to.equal(5)

    it 'does change to min value when under range', ->
      expect(MathExt.clamp(-5, 0, 10)).to.equal(0)

    it 'does change to max value when over range', ->
      expect(MathExt.clamp(15, 0, 10)).to.equal(10)

  context 'vectorBetween', ->
    context 'when vector2 is exactly one unit above vector1', ->
      vector1 = null
      vector2 = null
      result = null

      beforeEach ->
        vector1 = {x: 0, y: 0}
        vector2 = {x: 0, y: -1}
        result = MathExt.vectorBetween(vector1, vector2)

      it 'should set the x attribue to 0', ->
        expect(result.x).to.equal(0)

      it 'should set the y attribue to -1', ->
        expect(result.y).to.equal(-1)

      it 'should set the magnitude attribue to 1', ->
        expect(result.magnitude).to.equal(1)

    context 'when vector2 is exactly two units above vector1', ->
      vector1 = null
      vector2 = null
      result = null

      beforeEach ->
        vector1 = {x: 0, y: 0}
        vector2 = {x: 0, y: -2}
        result = MathExt.vectorBetween(vector1, vector2)

      it 'should set the x attribue to 0', ->
        expect(result.x).to.equal(0)

      it 'should set the y attribue to -1', ->
        expect(result.y).to.equal(-1)

      it 'should set the magnitude attribue to 1', ->
        expect(result.magnitude).to.equal(2)

    context 'when vector2 is exactly one unit to the right of vector1', ->
      vector1 = null
      vector2 = null
      result = null

      beforeEach ->
        vector1 = {x: 0, y: 0}
        vector2 = {x: 1, y: 0}
        result = MathExt.vectorBetween(vector1, vector2)

      it 'should set the x attribue to 0', ->
        expect(result.x).to.equal(1)

      it 'should set the y attribue to -1', ->
        expect(result.y).to.equal(0)

      it 'should set the magnitude attribue to 1', ->
        expect(result.magnitude).to.equal(1)

    context 'when vector2 is exactly two units above vector1', ->
      vector1 = null
      vector2 = null
      result = null

      beforeEach ->
        vector1 = {x: 0, y: 0}
        vector2 = {x: 2, y: 0}
        result = MathExt.vectorBetween(vector1, vector2)

      it 'should set the x attribue to 0', ->
        expect(result.x).to.equal(1)

      it 'should set the y attribue to -1', ->
        expect(result.y).to.equal(0)

      it 'should set the magnitude attribue to 1', ->
        expect(result.magnitude).to.equal(2)

    context 'when vector2 is exactly one unit above and one unit to the right of vector1', ->
      vector1 = null
      vector2 = null
      result = null

      beforeEach ->
        vector1 = {x: 0, y: 0}
        vector2 = {x: 1, y: 1}
        result = MathExt.vectorBetween(vector1, vector2)

      it 'should set the x attribue to 1', ->
        expect(result.x).to.equal(0.7)

      it 'should set the y attribue to 1', ->
        expect(result.y).to.equal(0.7)

      it 'should set the magnitude attribue to 1', ->
        expect(result.magnitude).to.within(1, 2)

