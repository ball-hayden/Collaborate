module Collaborate
  # Defines a text-based document that can be collaboratively edited.
  module Document
    extend ActiveSupport::Concern

    class_methods do
      def collaborative_attributes(*attributes)
        return @collaborative_attributes if attributes.size == 0

        @collaborative_attributes = ActiveSupport::HashWithIndifferentAccess[attributes.map do |attribute|
          [attribute, DocumentAttribute.new(self, attribute)]
        end]

        bind_collaborative_document_attributes
      end

      private

      def bind_collaborative_document_attributes
        collaborative_attributes.each do |_attribute, collaborate_attribute|
          bind_collaborative_document_attribute(collaborate_attribute)
        end
      end

      def bind_collaborative_document_attribute(collaborate_attribute)
        define_method("#{collaborate_attribute.attribute}") do
          Rails.cache.read(collaborate_attribute.collaborate_attribute_cache_key(id)) || super()
        end

        define_method("#{collaborate_attribute.attribute}=") do |value|
          super(value)

          Rails.cache.write(collaborate_attribute.collaborate_attribute_cache_key(id), value)
        end
      end
    end

    def apply_operation(data)
      operation = OT::TextOperation.from_a data['operation']
      attribute = data['attribute']

      self.class.collaborative_attributes[attribute].apply_operation(self, operation)
    end

    def clear_collaborate_cache(attribute)
      collaborate_attribute = self.class.collaborative_attributes[attribute]

      Rails.cache.delete(collaborate_attribute.collaborate_attribute_cache_key(id))
    end
  end
end
