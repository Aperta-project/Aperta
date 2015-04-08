class Table < ActiveRecord::Base
  belongs_to :paper, inverse_of: :tables

  validates :paper_id, presence: true
end
