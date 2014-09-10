class Author < ActiveRecord::Base
  belongs_to :author_group, inverse_of: :authors
  belongs_to :custom_author, polymorphic: true
  acts_as_list scope: :author_group

  validates :author_group, presence: true

  # validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  # validates :email, format: Devise.email_regexp
end
