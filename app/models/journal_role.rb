class JournalRole < ActiveRecord::Base
  include Roleable

  belongs_to :user, inverse_of: :journal_roles
  belongs_to :journal, inverse_of: :journal_roles

  validates :user, :journal, presence: true
end
