require 'rails_helper'

module Collaborate
  RSpec.describe Document, type: :model do
    let(:example_class) { ::Document }
    let(:example_instance) { example_class.create! }

    it 'should allow collaborative attributes do be defined' do
      expect(example_class.collaborative_attributes).to match_array ['title', 'body']
    end

    it 'should override setters for collaborative_attributes' do
      expect(example_instance).to receive_message_chain(:collaborative_attribute, :'value=')
      example_instance.body = 'something'
    end

    it 'should update the cache following an update_attribute / update_attributes' do
      example_instance.update_attribute(:body, 'Test Body')
      expect(example_instance.body).to eq 'Test Body'

      example_instance.update_attributes(body: 'Another Body')
      expect(example_instance.body).to eq 'Another Body'
    end

    it 'should mark any attributes which have cached changes as dirty' do
      example_instance.update_attribute(:body, 'Test Body')

      example_instance.body = 'Another Body'
      example_instance.reload

      expect(example_instance.body).to eq 'Another Body'
      expect(example_instance.body_changed?).to eq true

      example_instance.clear_collaborative_cache(:body)
      example_instance.reload

      expect(example_instance.body).to eq 'Test Body'
    end
  end
end
