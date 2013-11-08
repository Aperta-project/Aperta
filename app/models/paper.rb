class Paper < ActiveRecord::Base
  PAPER_TYPES = %w(research front_matter)

  after_initialize :initialize_defaults

  belongs_to :user
  has_many :declarations

  accepts_nested_attributes_for :declarations

  validates :paper_type, inclusion: { in: PAPER_TYPES }

  private

  def initialize_defaults
    self.paper_type = 'research' if paper_type.blank?
    self.declarations = Declaration.default_declarations if declarations.blank?
  end
end
