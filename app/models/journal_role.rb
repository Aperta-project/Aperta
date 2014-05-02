class JournalRole < ActiveRecord::Base
  include Roleable

  belongs_to :user
  belongs_to :journal

  validates :user, :journal, presence: true
end
