#= require cable
#= require collaborate

cable = Cable.createConsumer "ws://localhost:28080"

new Collaborate(cable, 'DocumentChannel', documentId)

$('#body').on 'change', ->
