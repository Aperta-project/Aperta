class Role < ActiveRecord::Base
  include Roleable

  belongs_to :journal, inverse_of: :roles
  has_many :journal_roles, inverse_of: :role

  validates :name, presence: true
  validates :name, uniqueness: { scope: :journal_id }
end
