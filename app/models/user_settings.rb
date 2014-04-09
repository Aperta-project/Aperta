class UserSettings < ActiveRecord::Base
  belongs_to :user
  has_many :flows, dependent: :destroy

  after_create :add_flows

  def add_flows
    [Flow.templates.values].each do |attrs|
      flows.create! attrs
    end
  end
end
