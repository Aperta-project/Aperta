class Author < ActiveRecord::Base
  belongs_to :paper
  acts_as_list scope: :author

  validates :position, presence: true
end
