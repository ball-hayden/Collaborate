Collaborate.CollaborativeAttribute = class CollaborateAttribute
  constructor: (@collaborate, @attribute) ->
    throw new Exception('You must specify an attribute to collaboratively edit') unless @attribute

    new Collaborate.Events(this)

    @documentId = @collaborate.documentId
    @cable = new Collaborate.AttributeCable @, @collaborate.cable, @attribute

    @documentVersion = 0
    @state = new Synchronized(this)

  localOperation: (operation) =>
    return if operation.isNoop()

    @documentVersion++
    @state.localOperation(operation)

  remoteOperation: (data) =>
    throw new Error('Received out of sequence operation') unless data.version == (@documentVersion + 1)

    @documentVersion++

    @state.remoteOperation(data)

    @trigger 'remoteOperation', data.operation

  receiveAck: (data) =>
    @state.receiveAck(data)

  class State
    constructor: (collaborativeAttribute) ->
      @collaborativeAttribute = collaborativeAttribute

  class Synchronized extends State
    localOperation: (operation) =>
      @collaborativeAttribute.cable.sendOperation
        operation: operation
        version: @collaborativeAttribute.documentVersion

      @collaborativeAttribute.state = new AwaitingAck(@collaborativeAttribute, operation)

    receiveAck: (data) ->
      console.error "Received an ack for version #{data.version} whilst in Synchronized state."

    remoteOperation: (data) ->
      # Noop. We don't need to transform the operation as it can be applied
      # happily

  class AwaitingAck extends State
    constructor: (collaborativeAttribute, operation) ->
      super

      @operation = operation

    localOperation: (operation) =>
      if @buffer
        @buffer.compose(operation)
      else
        @buffer = operation

    receiveAck: (data) =>
      unless @buffer
        @collaborativeAttribute.state = new Synchronized(@collaborativeAttribute)
        return

      @operation = @buffer

      @collaborativeAttribute.cable.sendOperation
        operation: operation
        version: @collaborativeAttribute.documentVersion

    remoteOperation: (data) =>
      # Ok. We have something to do...

      # First, transform our pending operation and the received operation
      pair = ot.TextOperation.transform(@operation, data.operation)

      @operation = pair[0]
      data.operation = pair[1]

      # If we have no buffer, we can apply return the new received operation and
      # continue.
      return unless @buffer

      # If we have a buffer, let's transform again
      pair = ot.TextOperation.transform(@buffer, data.operation)

      @buffer = pair[0]
      data.operation = pair[1]
