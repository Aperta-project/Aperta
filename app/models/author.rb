class Author < ActiveRecord::Base
  has_many :affiliations, inverse_of: :affiliable, as: :affiliable
  # belongs_to :paper, inverse_of: :authors

  validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  validates :email, format: Devise.email_regexp
end
