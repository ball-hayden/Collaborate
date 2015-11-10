require 'rails_helper'
require 'redis'

module Collaborate
  RSpec.describe CollaborationChannel do
    let(:example_document) { ::Document.create! }

    class TestChannel < CollaborationChannel
      def initialize(document = nil)
        @document = document
      end

      def document_type
        ::Document
      end

      def transmit(*_args); end

      def stream_from(*_args); end
    end

    subject(:channel) do
      TestChannel.new(example_document)
    end

    it 'should inform a client of current attribute versions when subscribing to a document' do
      allow_any_instance_of(DocumentAttribute).to receive(:version).and_return(2)

      expect(channel).to receive(:transmit).with(document_id: example_document.id, action: 'attribute', attribute: 'body', version: 2)
      expect(channel).to receive(:transmit).with(document_id: example_document.id, action: 'attribute', attribute: 'title', version: 2)

      channel.document('id' => example_document.id)
    end

    it 'should broadcast new operations' do
      # N.B - if this fails with "ERR unknown command 'to_str'", it means the
      # message didn't match.
      expect_any_instance_of(Redis).to receive(:publish)
        .with(
          "collaborate.documents.#{example_document.id}.operations",
          "{\"version\":1,\"document_id\":#{example_document.id},\"attribute\":\"body\",\"operation\":[\"test\"],\"sent_version\":1}"
        )

      channel.operation(
        'version' => 1,
        'document_id' => example_document.id,
        'attribute' => 'body',
        'operation' => ['test']
      )

      expect(example_document.collaborative_body).to eq 'test'
    end
  end
end
