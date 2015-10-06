window.Collaborate.Events = class Events
  _listeners: []

  constructor: (object) ->
    object.on = @on
    object.off = @off
    object.trigger = @trigger

  on: (eventName, callback) =>
    @_listeners[eventName] ||= []

    @_listeners[eventName].push callback

  off: (eventName, callback) =>
    unless callback
      delete @_listeners[eventName]
      return

    index = @_listeners[eventName].indexOf(callback)
    @_listeners.splice(index, 1)

  trigger: (eventName, args...) =>
    for callback in @_listeners[eventName]
      callback(args...)
