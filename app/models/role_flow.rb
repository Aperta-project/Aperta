class RoleFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :role, inverse_of: :flows

  validates :title, inclusion: { in: FlowTemplate.valid_titles }
end
