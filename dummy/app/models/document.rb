class Document < ActiveRecord::Base
  include Collaborate::Document

  collaborative_attributes :body, :title
end
