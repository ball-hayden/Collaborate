window.Collaborate = class Collaborate
  constructor: (cable, channel, documentId) ->
    @documentId = documentId
    @cable = new Collaborate.Cable(@, cable, channel)
