class Flow < ActiveRecord::Base
  store_accessor :query, :state_query, :assigned_query, :type_query, :role_query

  attr_accessor :papers
  belongs_to :role, inverse_of: :flows
  has_one :journal, through: :role
  has_many :user_flows, dependent: :destroy
  has_many :users, through: :user_flows

  acts_as_list scope: :role

  scope :defaults, -> { where(role_id: nil) }

  def default?
    role_id.nil?
  end

  # hstore only stores strings
  def assigned_query
    return (super == 'true') if %w{true false}.include? super
    super
  end

  def assigned?
    assigned_query == true
  end
end
