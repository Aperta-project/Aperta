class Paper < ActiveRecord::Base
  PAPER_TYPES = %w(research front_matter)

  after_initialize ->(p) { p.paper_type = 'research' }, unless: :paper_type

  belongs_to :user

  validates :paper_type, inclusion: { in: PAPER_TYPES }
end
