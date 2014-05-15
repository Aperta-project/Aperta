class Role < ActiveRecord::Base
  include Roleable

  belongs_to :journal, inverse_of: :roles
  has_many :journal_roles, inverse_of: :role
end
