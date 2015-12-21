class Flow < ActiveRecord::Base
  attr_accessor :papers
  belongs_to :old_role, inverse_of: :flows
  has_one :journal, through: :old_role
  has_many :user_flows, dependent: :destroy
  has_many :users, through: :user_flows

  acts_as_list scope: :old_role

  serialize :query, Hash

  scope :defaults, -> { where(old_role_id: nil) }

  def default?
    old_role_id.nil?
  end
end
