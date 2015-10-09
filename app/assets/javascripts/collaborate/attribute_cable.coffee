Collaborate.AttributeCable = class Cable
  unackedOps: []

  version: 0

  constructor: (@collaborativeAttribute, @cable, @attribute) ->
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
    @version = data.version

    @collaborativeAttribute.remoteOperation data
