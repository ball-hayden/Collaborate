Collaborate.AttributeCable = class Cable
  unackedOps: []

  constructor: (@collaborativeAttribute, @cable, @attribute) ->
    @cable.addAttribute(@attribute, @)

  sendOperation: (data) =>
    data.attribute = @attribute

    @unackedOps.push data.version
    @cable.sendOperation(data)

  receiveOperation: (data) =>
    console.debug "Receive operation #{data.operation.toString()} for #{@attribute}"
    console.debug "Document Version: #{data.version}"

    data.operation = ot.TextOperation.fromJSON(data.operation)

    if data.client_id == @cable.clientId
      ackIndex = @unackedOps.indexOf(data.version)
      if ackIndex > -1
        @unackedOps.splice(ackIndex, 1)
        @collaborativeAttribute.receiveAck data
      else
        console.warn "Operation #{data.verion} reAcked"

    else
      @collaborativeAttribute.remoteOperation data
