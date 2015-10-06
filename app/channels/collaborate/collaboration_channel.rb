module Collaborate
  # An ActionCable channel for collaboration
  class CollaborationChannel < ApplicationCable::Channel
    # Set the document this client is working on
    def document(data)
      @document = document_type.find(data['id'])

      Rails.logger.debug "Set document to #{@document}"
    end

    def transform(data)
      @document.transform(data)
    end

    private

    def document_type
      fail 'You must override the document_type method to specify your document model'
    end
  end
end
