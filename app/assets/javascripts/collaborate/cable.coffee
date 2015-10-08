Collaborate.Cable = class Cable
  unackedOps: []
  attributeCables: {}

  constructor: (@collaborate, cable, channel) ->
    @subscription = cable.subscriptions.create channel,
      connected: @connected
      received: @received

  addAttribute: (attribute, attributeCable) =>
    @attributeCables[attribute] = attributeCable

  connected: =>
    # This shouldn't be necessary, but ActionCable doesn't seem to be able
    # to cope with finding the session immediately yet.
    setTimeout =>
      @subscription.perform 'document', { id: @collaborate.documentId }
      console.info 'Document Setup Complete'
    , 1000

  received: (data) =>
    console.debug "Received data in document channel"

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

    @subscription.perform 'operation', data

  subscribed: (data) ->
    @clientId = data.client_id

    console.debug "Set client ID as #{@clientId}"

  receiveOperation: (data) =>
    @attributeCables[data.attribute].receiveOperation(data)
