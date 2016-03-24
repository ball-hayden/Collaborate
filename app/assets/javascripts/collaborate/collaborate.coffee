window.Collaborate = class Collaborate
  constructor: (cable, channel, documentId) ->
    @documentId = documentId
    @cable = new Collaborate.Cable(@, cable, channel)
    @attributes = {}

  addAttribute: (attribute) =>
    @attributes[attribute] = new Collaborate.CollaborativeAttribute(@, attribute)

  destroy: ->
    for name, attribute of @attributes
      attribute.destroy()

    @cable.destroy()
