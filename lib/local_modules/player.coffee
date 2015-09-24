uuid = require('uuid')

randomName = ->
  names = [
    'joe', 'bob', 'greg',
    'anna', 'chelsea', 'tina'
  ]
  things = [
    'foo', 'bar', 'baz',
      'fizz', 'buzz'
  ]

  [
    _.sample(names)
    _.sample(things)
    Date.now()
  ].join('_')

class Player
  constructor: (name = null) ->
    @name = name || randomName()
    @uuid = uuid.v4()


module.exports = Player

