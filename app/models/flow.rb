class Flow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :role, inverse_of: :flows
  has_one :journal, through: :role
  has_many :user_flows

  acts_as_list scope: :role

  serialize :query, Array
end
