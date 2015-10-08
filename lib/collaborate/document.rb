module Collaborate
  # Defines a text-based document that can be collaboratively edited.
  module Document
    extend ActiveSupport::Concern

    class_methods do
      def collaborative_attributes(*attributes)
        return @collaborative_attributes if attributes.size == 0

        @collaborative_attributes = attributes

        bind_collaborative_document_attributes
      end

      private

      def bind_collaborative_document_attributes
        collaborative_attributes.each do |attribute|
          bind_collaborative_document_attribute(attribute)
        end
      end

      def bind_collaborative_document_attribute(attribute)
        define_method("#{attribute}") do
          collaborative_attribute(attribute).value
        end

        define_method("#{attribute}=") do |value|
          super(value)

          collaborative_attribute(attribute).value = value
        end
      end
    end

    def collaborative_attribute(attribute_name)
      @collaborative_attributes ||= {}
      attribute = @collaborative_attributes[attribute_name]

      return attribute if attribute.present?

      @collaborative_attributes[attribute_name] = DocumentAttribute.new(self, attribute_name)
    end

    def apply_operation(data)
      operation = OT::TextOperation.from_a data['operation']
      attribute = data['attribute']

      collaborative_attribute(attribute).apply_operation(operation)
    end

    def clear_collaborate_cache(attribute)
      collaborative_attribute(attribute).clear_cache
    end
  end
end
