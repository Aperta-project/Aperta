class AwesomeAuthor < ActiveRecord::Base
  belongs_to :awesome_task
  has_one :author, as: :custom_author

  delegate :first_name, :middle_initial, :last_name, :email, to: :author

  validates :awesome_name, presence: true
end
