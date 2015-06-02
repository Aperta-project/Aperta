class CoverLetter < ActiveRecord::Base
  belongs_to :paper

  validates :paper, presence: true
end
