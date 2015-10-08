window.Collaborate.Events = class Events
  constructor: (object) ->
    @_listeners = []

    object.on = @on.bind(object)
    object.off = @off.bind(object)
    object.trigger = @trigger.bind(object)

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
