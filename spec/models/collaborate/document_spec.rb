require 'rails_helper'

module Collaborate
  RSpec.describe Document, type: :model do
    let(:example_class) { ::Document }
    let(:example_instance) { example_class.create! }

    it 'should allow collaborative attributes do be defined' do
      expect(example_class.collaborative_attributes).to match_array ['title', 'body']
    end

    it 'should define getters for collaborative_attributes' do
      expect(example_instance).to receive_message_chain(:collaborative_attribute, value: 'Test')
      expect(example_instance.collaborative_body).to eq 'Test'
    end

    it 'should define setters for collaborative_attributes' do
      expect(example_instance).to receive_message_chain(:collaborative_attribute, :'value=')
      example_instance.collaborative_body = 'something'
    end

    it 'should update the cache following an update_attribute / update_attributes' do
      example_instance.update_attribute(:body, 'Test Body')
      expect(example_instance.collaborative_body).to eq 'Test Body'

      example_instance.update_attributes(body: 'Another Body')
      expect(example_instance.collaborative_body).to eq 'Another Body'
    end
  end
end
