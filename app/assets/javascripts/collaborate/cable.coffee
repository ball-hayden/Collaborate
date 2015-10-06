Collaborate.Cable = class Cable
  unackedOps: []

  constructor: (collaborate, cable, channel) ->
    @collaborate = collaborate

    @subscription = cable.subscriptions.create channel,
      connected: @connected
      received: @received

  connected: =>
    # This shouldn't be necessary, but ActionCable doesn't seem to be able
    # to cope with finding the session immediately yet.
    setTimeout =>
      @subscription.perform 'document', { id: @collaborate.documentId }
      console.info 'Document Setup Complete'
    , 1000

  received: (data) =>
    console.debug "Received data in solution channel"

    switch data.action
      when 'subscribed'
        @subscribed(data)
      when 'operation'
        @receiveOperation(data)
      else
        console.warn "#{data.action} unhandled"
        console.info data

  sendOperation: (data) =>
    data.client_id = @clientId

    @unackedOps.push data.version
    @subscription.perform 'operation', data

  subscribed: (data) ->
    @clientId = data.client_id

    console.debug "Set client ID as #{@clientId}"

  receiveOperation: (data) =>
    console.debug "Receive operation #{data.operation.toString()}"
    console.debug "Document Version: #{data.version}"

    data.operation = ot.TextOperation.fromJSON(data.operation)

    if data.client_id == @clientId
      ackIndex = @unackedOps.indexOf(data.version)
      if ackIndex > -1
        @unackedOps.splice(ackIndex, 1)
        @collaborate.receiveAck data
      else
        console.warn "Operation #{data.verion} reAcked"

    else
      @collaborate.remoteOperation data
