class RoleFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :role, inverse_of: :flows
  has_one :journal, through: :role

  acts_as_list scope: :role

  serialize :query, Array

  def self.create_default_flows!(role)
    FlowQuery::FLOW_TITLES.each do |title|
      role.flows.find_or_create_by!(title: title)
    end
  end
end
