Collaborate.Cable = class Cable
  constructor: (@collaborate, cable, channel) ->
    @unackedOps = []
    @attributeCables = {}
    @documentId = @collaborate.documentId

    @subscription = cable.subscriptions.create { channel: channel, documentId: @documentId },
      connected: @connected
      received: @received


  addAttribute: (attribute, attributeCable) =>
    @attributeCables[attribute] = attributeCable

  connected: =>
    # This shouldn't be necessary, but ActionCable doesn't seem to be able
    # to cope with finding the session immediately yet.
    setTimeout =>
      @subscription.perform 'document', { id: @documentId }
      console.info 'Document Setup Complete'
    , 200

  received: (data) =>
    switch data.action
      when 'subscribed'
        @subscribed(data)
      when 'attribute'
        @receiveAttribute(data)
      when 'operation'
        @receiveOperation(data)
      else
        console.warn "#{data.action} unhandled"
        console.info data

  sendOperation: (data) =>
    data.client_id = @clientId
    data.document_id = @documentId

    @subscription.perform 'operation', data

  subscribed: (data) ->
    @clientId = data.client_id

    console.debug "Set client ID as #{@clientId}"

  receiveAttribute: (data) =>
    return unless data.document_id == @documentId

    attributeCable = @attributeCables[data.attribute]

    unless attributeCable
      console.warn "Received collaboration message for #{data.attribute}, but it has not been registered"
      return

    attributeCable.receiveAttribute(data)

  receiveOperation: (data) =>
    return unless data.document_id == @documentId

    attributeCable = @attributeCables[data.attribute]

    unless attributeCable
      console.warn "Received collaboration message for #{data.attribute}, but it has not been registered"
      return

    attributeCable.receiveOperation(data)
