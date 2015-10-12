module Collaborate
  class DocumentAttribute
    attr_reader :document, :attribute

    def initialize(document, attribute)
      @document = document
      @attribute = attribute

      @operations = []
    end

    # Based on https://github.com/Operational-Transformation/ot.js/blob/15d4e7/lib/server.js#L16
    def apply_operation(operation, client_version)
      Rails.logger.debug "Applying client version #{client_version}, server version: #{version}"

      unless client_version > operations.length
        operation = transform_old_operation(operation, client_version)
      end

      store_operation(operation)

      self.value = new_text(operation)

      return version, operation
    end

    def version
      operations.length
    end

    def value
      cached_value || document.attributes[attribute.to_s] || ''
    end

    def value=(value)
      return unless document.persisted?

      Rails.cache.write(value_key, value)
    end

    def clear_cache
      Rails.cache.delete(value_key)
    end

    def clear_operations_cache
      Rails.cache.delete(operations_key)
    end

    private

    def value_key
      "collaborate-#{document.class}-#{document.id}-#{attribute}"
    end

    def cached_value
      return unless document.persisted?

      Rails.cache.read(value_key)
    end

    def operations_key
      "collaborate-#{document.class}-#{document.id}-#{attribute}-operations"
    end

    def operations
      Rails.cache.read(operations_key) || []
    end

    def store_operation(operation)
      Rails.cache.write(operations_key, operations + [operation])
    end

    def new_text(operation)
      operation.apply value
    end

    def transform_old_operation(operation, client_version)
      server_version = version
      concurrent_operations = operations.slice(client_version - 1, server_version - client_version + 1)

      concurrent_operations.each do |other_operation|
        operation = OT::TextOperation.transform(operation, other_operation).first
      end

      return operation
    end
  end
end
