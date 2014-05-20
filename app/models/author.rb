class Author < ActiveRecord::Base
  validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  validates :email, format: Devise.email_regexp
  # belongs_to :paper, inverse_of: :authors
end
