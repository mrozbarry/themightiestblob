
CHANGE_EVENT = 'change'

class BaseStore
  constructor: ->
    @_eventMode = ''

  subscribe: (method) ->
    addEventListener(CHANGE_EVENT, method, false)

  unsubscribe: (method) ->
    removeEventListener(CHANGE_EVENT, method)

  publish: ->
    event = null
    if @_eventMode == ''
      event = @_publishDetectAndReturnEvent()

    else
      event = @[@_eventMode]()

    dispatchEvent event

  _publishDetectAndReturnEvent: ->
    try
      @_eventMode = '_publish'
      return @_publish()

    catch
      @_eventMode = '_publishLegacy'
      return @_publishLegacy()

  _publish: ->
    new Event(CHANGE_EVENT)

  _publishLegacy: ->
    event = document.createEvent('Event')
    event.initEvent(CHANGE_EVENT, true, true)

    event

module.exports = BaseStore

