window.Collaborate = class Collaborate
  attributes: []

  constructor: (cable, channel, documentId) ->
    @documentId = documentId
    @cable = new Collaborate.Cable(@, cable, channel)

  addAttribute: (attribute) =>
    @attributes[attribute] = new Collaborate.CollaborativeAttribute(@, attribute)
