class RoleFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :role, inverse_of: :flows

  validates :title, inclusion: { in: FlowTemplate.valid_titles }

  def self.create_default_flows!(role)
    FlowTemplate.templates.values.each do |attrs|
      role.flows.find_or_create_by!(attrs)
    end
  end
end
