#= require cable
#= require collaborate

cable = Cable.createConsumer "ws://localhost:28080"

collaborate = new Collaborate(cable, 'DocumentChannel', documentId, 'body')

new Collaborate.Adapters.TextAreaAdapter(collaborate, '#body')
