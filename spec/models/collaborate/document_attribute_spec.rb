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

        expect(example_attribute.value).to be_nil
        expect(example_document.collaborative_body).to be_nil
      end
    end

    context 'applying OT operations' do
      let(:operation1) { OT::TextOperation.new.insert('test') }
      let(:operation2) { OT::TextOperation.new.insert('this is a ') }

      it 'should apply a simple operation' do
        example_attribute.apply_operation(operation1, 1)

        expect(example_attribute.value).to eq 'test'
      end

      it "should transform a client's operation when necessary" do
        example_attribute.apply_operation(operation1, 1)

        example_attribute.apply_operation(operation2, 1)

        expect(example_attribute.value).to eq 'this is a test'
      end
    end
  end
end
