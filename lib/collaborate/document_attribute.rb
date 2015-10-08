module Collaborate
  class DocumentAttribute
    attr_reader :document, :attribute

    def initialize(document, attribute)
      @document = document
      @attribute = attribute
    end

    def apply_operation(operation)
      document.send "#{attribute}=", new_text(operation)
    end

    def value
      Rails.cache.read(cache_key) || document.attributes[attribute]
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
  end
end
