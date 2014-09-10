class AwesomeAuthor < ActiveRecord::Base
  belongs_to :awesome_task
  acts_as :author, dependent: :destroy

  validates :awesome_name, presence: true
end
