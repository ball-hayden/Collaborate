#= require cable
#= require collaborate

return unless documentId?

cable = Cable.createConsumer "ws://localhost:28080"

collaborate = new Collaborate(cable, 'DocumentChannel', documentId)

collaborativeBody = collaborate.addAttribute('body')
new Collaborate.Adapters.TextAreaAdapter(collaborativeBody, '#body')

collaborativeTitle = collaborate.addAttribute('title')
new Collaborate.Adapters.TextAreaAdapter(collaborativeTitle, '#title')
