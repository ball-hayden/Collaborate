class DocumentChannel < Collaborate::CollaborationChannel
  private

  def document_type
    Document
  end
end
