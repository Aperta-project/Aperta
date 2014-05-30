class Author < ActiveRecord::Base
  belongs_to :author_group, inverse_of: :authors
  acts_as_list scope: :author_group

  validates :position, presence: true

  # validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  # validates :email, format: Devise.email_regexp
end
