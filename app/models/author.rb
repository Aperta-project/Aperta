class Author < ActiveRecord::Base
  belongs_to :author_group, inverse_of: :authors

  # validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  # validates :email, format: Devise.email_regexp
end
