module Collaborate
  class DocumentAttribute
    attr_reader :document_class, :attribute

    def initialize(document_class, attribute)
      @document_class = document_class
      @attribute = attribute
    end

    def apply_operation(document, operation)
      document.send "#{attribute}=", new_text(document, operation)
    end

    def collaborate_attribute_cache_key(id)
      "collaborate-#{document_class}-#{id}-#{attribute}"
    end

    private

    def stored_text(document)
      document.send(attribute) || ''
    end

    def new_text(document, operation)
      operation.apply stored_text(document)
    end
  end
end
