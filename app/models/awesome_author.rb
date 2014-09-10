class AwesomeAuthor < ActiveRecord::Base
  has_one :author, as: :custom_author

  delegate :first_name, :middle_initial, :last_name, :email, to: :author

  # validates :first_name, :middle_initial, :last_name, :title, :department, presence: true
  # validates :email, format: Devise.email_regexp
end
