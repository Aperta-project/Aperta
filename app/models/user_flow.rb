class UserFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :flows

  validates :title, inclusion: { in: FlowQuery::FLOW_TITLES }
end
