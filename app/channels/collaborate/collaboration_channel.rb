module Collaborate
  # An ActionCable channel for collaboration
  class CollaborationChannel < ApplicationCable::Channel
    attr_reader :client_id

    def subscribed
      @client_id = SecureRandom.uuid

      transmit action: 'subscribed', client_id: client_id
    end

    # Subscribe to changes to a document
    def document(data)
      document = document_type.find(data['id'])

      @documents ||= []
      @documents << document

      send_attribute_versions(document)

      stream_from "collaborate.documents.#{document.id}.operations"
    end

    def operation(data)
      data = ActiveSupport::HashWithIndifferentAccess.new(data)
      document = document_type.find(data[:document_id])

      version, operation = document.apply_operation(data)

      data[:sent_version] = data[:version]
      data[:version] = version
      data[:operation] = operation.to_a

      ActionCable.server.broadcast "collaborate.documents.#{document.id}.operations", data
      begin
        perform_after_operation(data, document)
      rescueA
      end
    end

    private

    def document_type
      fail 'You must override the document_type method to specify your document model'
    end

    # Send out initial versions
    def send_attribute_versions(document)
      document_type.collaborative_attributes.each do |attribute_name|
        attribute = document.collaborative_attribute(attribute_name)

        transmit(
          document_id: document.id,
          action: 'attribute',
          attribute: attribute_name,
          version: attribute.version
        )
      end
    end
  end
end
