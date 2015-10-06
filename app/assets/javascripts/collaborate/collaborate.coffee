window.Collaborate = class Collaborate
  constructor: (cable, channel, documentId) ->
    new Collaborate.Events(this)

    @documentId = documentId

    @documentVersion = 0

    @cable = new Collaborate.Cable(@, cable, channel)
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
    constructor: (collaborate) ->
      @collaborate = collaborate

  class Synchronized extends State
    localOperation: (operation) =>
      @collaborate.cable.sendOperation
        operation: operation
        version: @collaborate.documentVersion

      @collaborate.state = new AwaitingAck(@collaborate, operation)

    receiveAck: (data) ->
      console.error "Received an ack for version #{data.version} whilst in Synchronized state."

    remoteOperation: (data) ->
      # Noop. We don't need to transform the operation as it can be applied
      # happily

  class AwaitingAck extends State
    constructor: (collaborate, operation) ->
      super

      @operation = operation

    localOperation: (operation) =>
      @buffer ||= new ot.TextOperation()
      @buffer.compose(operation)

    receiveAck: (data) =>
      unless @buffer
        @collaborate.state = new Synchronized(@collaborate)
        return

      @operation = @buffer

      @collaborate.cable.sendOperation
        operation: operation
        version: @collaborate.documentVersion

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
