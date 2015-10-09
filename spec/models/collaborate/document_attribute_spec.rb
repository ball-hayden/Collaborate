require 'rails_helper'

module Collaborate
  RSpec.describe DocumentAttribute, type: :model do
    let(:example_document) { ::Document.create! }
    subject(:example_attribute) { example_document.collaborative_attribute(:body) }

    context 'for an unpersisted document' do
      let(:example_document) { ::Document.new }

      it 'should not cache the attribute value' do
        expect(Rails.cache).to_not receive(:write)

        example_document.body = 'something'

        expect(example_attribute.value).to eq 'something'
      end

      it 'should not attempt to read a cached value' do
        expect(Rails.cache).to_not receive(:read)

        expect(example_document.body).to be_nil
      end
    end
  end
end
