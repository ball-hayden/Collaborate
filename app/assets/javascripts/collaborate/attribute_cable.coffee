Collaborate.AttributeCable = class Cable
  constructor: (@collaborativeAttribute, @cable, @attribute) ->
    @unackedOps = []
    @version = 0

    @cable.addAttribute(@attribute, @)

  receiveAttribute: (data) =>
    @version = data.version

  sendOperation: (data) =>
    @version++

    data.attribute = @attribute
    data.version = @version

    console.debug "Send #{@attribute} version #{data.version}: #{data.operation.toString()}"

    @unackedOps.push data.version
    @cable.sendOperation(data)

  receiveOperation: (data) =>
    data.operation = ot.TextOperation.fromJSON(data.operation)
    @version = data.version

    console.debug "Receive #{@attribute} version #{data.version}: #{data.operation.toString()} from #{data.client_id}"

    if data.client_id == @cable.clientId
      @receiveAck(data)
    else
      @receiveRemoteOperation(data)

  receiveAck: (data) =>
    ackIndex = @unackedOps.indexOf(data.sent_version)
    if ackIndex > -1
      @unackedOps.splice(ackIndex, 1)
      @collaborativeAttribute.receiveAck data
    else
      console.warn "Operation #{data.sent_version} reAcked"

  receiveRemoteOperation: (data) =>
    @collaborativeAttribute.remoteOperation data
