#= require cable
#= require collaborate

cable = Cable.createConsumer "ws://localhost:28080"

collaborate = new Collaborate(cable, 'DocumentChannel', documentId)

new Collaborate.Adapters.TextAreaAdapter(collaborate, '#body')
