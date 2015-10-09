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

      send_attribute_versions

      stream_from "collaborate.documents.#{@document.id}.operations"
    end

    def operation(data)
      version, operation = @document.apply_operation(data)

      data['sent_version'] = data['version']
      data['version'] = version
      data['operation'] = operation.to_a

      ActionCable.server.broadcast "collaborate.documents.#{@document.id}.operations", data
    end

    private

    def document_type
      fail 'You must override the document_type method to specify your document model'
    end

    # Send out initial versions
    def send_attribute_versions
      document_type.collaborative_attributes.each do |attribute_name|
        attribute = @document.collaborative_attribute(attribute_name)

        transmit action: 'attribute', attribute: attribute_name, version: attribute.version
      end
    end
  end
end
