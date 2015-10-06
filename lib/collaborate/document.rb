module Collaborate
  # Defines a text-based document that can be collaboratively edited.
  module Document
    extend ActiveSupport::Concern

    def applyOperation(data)
      operation = data['operation']

      Rails.logger.debug "Applying #{operation} to #{self}"
    end
  end
end
