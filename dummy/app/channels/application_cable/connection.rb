module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :guid

    def connect
      self.guid = SecureRandom.uuid
    end
  end
end
