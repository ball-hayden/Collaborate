module Collaborate
  # An ActionCable channel for collaboration
  class CollaborationChannel < ApplicationCable::Channel
    attr_reader :client_id

    def subscribed
      @client_id = SecureRandom.uuid

      transmit action: 'subscribed', client_id: client_id
    end

    # Set the document this client is working on
    def document(data)
      @document = document_type.find(data['id'])

      stream_from "collaborate.documents.#{@document.id}.operations"
    end

    def operation(data)
      @document.apply_operation(data)

      ActionCable.server.broadcast "collaborate.documents.#{@document.id}.operations", data
    end

    private

    def document_type
      fail 'You must override the document_type method to specify your document model'
    end
  end
end
