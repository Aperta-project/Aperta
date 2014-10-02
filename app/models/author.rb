class Author < ActiveRecord::Base
  belongs_to :paper
  acts_as_list

  validates :position, presence: true
end
