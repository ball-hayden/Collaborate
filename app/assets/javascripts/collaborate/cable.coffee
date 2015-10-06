Collaborate.Cable = class Cable
  constructor: (collaborate, cable, channel) ->
    @collaborate = collaborate

    @subscription = cable.subscriptions.create channel,
      connected: =>
        # This shouldn't be necessary, but ActionCable doesn't seem to be able
        # to cope with finding the session immediately yet.
        setTimeout =>
          @subscription.perform 'document', { id: @collaborate.documentId }
        , 1000

      received: (data) ->
        console.log "Received #{data} in solution channel"
