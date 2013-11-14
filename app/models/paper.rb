class Paper < ActiveRecord::Base
  PAPER_TYPES = %w(research front_matter)

  after_initialize :initialize_defaults

  belongs_to :user
  has_many :declarations, -> { order :id }

  accepts_nested_attributes_for :declarations
  serialize :authors, Array

  validates :paper_type, inclusion: { in: PAPER_TYPES }

  def self.submitted
    where(submitted: true)
  end

  def self.ongoing
    where(submitted: false)
  end

  private

  def initialize_defaults
    self.paper_type = 'research' if paper_type.blank?
    self.declarations = Declaration.default_declarations if declarations.blank?
  end
end
