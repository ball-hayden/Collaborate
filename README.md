# Collaborate

Collaborate is a Rails Engine that allows Real-Time collaboration between users.

Collaborate is still a work in progress, and currently only text attributes may
be collaboratively edited.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'collaborate'
```

And then execute:

    $ bundle

## Getting Started

### Prerequisites

You will need to have ActionCable set up. In particular, you will need an
`ApplicationCable::Channel` and `ApplicationCable::Connection`.

More information about setting up ActionCable can be found in its README.

### Model Setup

```ruby
class Document < ActiveRecord::Base
  # Include the Collaborate::Document concern
  include Collaborate::Document

  # Choose which attributes may be edited collaboratively
  collaborative_attributes :body, :title
end
```

Adding `collaborative_attributes` will define an extra attribute on the model
prefixed with `collaborative_` (e.g `collaborative_body`). We must use that
over `body` whenever we wish to allow realtime collaboration.

Bear in mind that the `collaborative_` attributes are stored only in the Rails
cache. You must save these attributes where appropriate:

```ruby
document = Document.first
document.body = document.collaborative_body
document.save!

# Or, using the commit_collaborative_attributes convenience method:

document.commit_collaborative_attributes(:body)
document.commit_collaborative_attributes(:body, :title)

```

### Channel Setup

You will need to set up a collaboration channel for each model that is being
collaboratively edited.

```ruby
class DocumentChannel < Collaborate::CollaborationChannel
  private

  # Set the Model class that we are editing.
  def document_type
    Document
  end
end
```

### View

As mentioned in Model Setup, we must use `collaborative_` attributes over normal
attributes when getting the values of collaborative attributes:

```erb
<%# app/views/documents/show.html.erb %>

<input id="title" type="text" value="<%= @document.collaborative_title %>">

<textarea id="body" rows="8" cols="40"><%= @document.collaborative_body %></textarea>

<%= link_to 'Back', documents_path %>

<script>
var documentId = <%= @document.id %>
</script>
```

### JavaScript

Add `collaborate` to your `application.coffee` asset, after actionable:

```coffeescript
#= require cable
#= require collaborate
```

Then, wherever appropriate:

```coffeescript
# Create a new ActionCable consumer
cable = Cable.createConsumer 'ws://localhost:28080'

# Set up our collaboration object. `documentId` is (as you may expect) the ID
# of the document that is being edited.
collaborate = new Collaborate(cable, 'DocumentChannel', documentId)

# We now specify the two attributes we are editing.
collaborativeTitle = collaborate.addAttribute('title')
collaborativeBody = collaborate.addAttribute('body')

# Here we are using a TextAreaAdapter - this binds to a textarea element.
# The TextAreaAdapter is the only adapter that is bundled with Collaborate.
# There is currently an AceAdapter in progress, and other adapters are
# relatively easy to write.
new Collaborate.Adapters.TextAreaAdapter(collaborativeTitle, '#title')
new Collaborate.Adapters.TextAreaAdapter(collaborativeBody, '#body')
```

## Underlying Technology

Collaborate uses [ActionCable](https://github.com/rails/actioncable) to allow
realtime communication between clients and the server.

All changes to an attribute are represented by an Operation. Operations are sent
from the client to the server, which will then transform them as appropriate to
ensure that they are applied in the same order.
