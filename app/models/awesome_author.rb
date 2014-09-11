class AwesomeAuthor < ActiveRecord::Base
  belongs_to :awesome_authors_task
  acts_as :author, dependent: :destroy

  validates :awesome_name, presence: true
end
