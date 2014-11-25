class UserFlow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :user, inverse_of: :flows
  belongs_to :role_flow, inverse_of: :user_flows
end
