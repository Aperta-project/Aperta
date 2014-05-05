module Roleable
  extend ActiveSupport::Concern
  included do
    def self.admins
      where(admin: true)
    end

    def self.editors
      where(editor: true)
    end

    def self.reviewers
      where(reviewer: true)
    end
  end
end
