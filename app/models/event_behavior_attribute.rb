class EventBehaviorAttribute < ActiveRecord::Base
  include Attribute

  belongs_to :event_behavior
end
