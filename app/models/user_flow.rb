class UserFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :user_flows
  belongs_to :flow, inverse_of: :user_flows

  delegate :title, to: :flow
end
