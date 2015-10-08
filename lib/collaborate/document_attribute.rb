module Collaborate
  class DocumentAttribute
    attr_reader :document, :attribute

    def initialize(document, attribute)
      @document = document
      @attribute = attribute

      @operations = []
    end

    # Based on https://github.com/Operational-Transformation/ot.js/blob/15d4e7/lib/server.js#L16
    def apply_operation(operation, version)
      if version <= @operations.length
        operation = transform_old_operation(operation, version)
      end

      document.send "#{attribute}=", new_text(operation)

      @operations << operation

      return @operations.length
    end

    def value
      Rails.cache.read(cache_key) || document.attributes[attribute.to_s]
    end

    def value=(value)
      Rails.cache.write(cache_key, value)
    end

    def clear_cache
      Rails.cache.delete(cache_key)
    end

    private

    def cache_key
      "collaborate-#{document.class}-#{document.id}-#{attribute}"
    end

    def new_text(operation)
      operation.apply value
    end

    def transform_old_operation(operation, version)
      concurrent_operations = @operations.slice(version, @operations.length - version)

      concurrent_operations.each do |other_operation|
        operation = OT::TextOperation.transform(operation, other_operation).first
      end

      return operation
    end
  end
end
