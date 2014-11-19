class RoleFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :role, inverse_of: :flows

  acts_as_list scope: :role

  validates :title, inclusion: { in: FlowQuery::FLOW_TITLES }

  def self.create_default_flows!(role)
    FlowQuery::FLOW_TITLES.each do |title|
      role.flows.find_or_create_by!(title: title)
    end
  end
end
