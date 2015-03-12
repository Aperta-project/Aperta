class Activity < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :actor, class_name: "User"

  def self.public
    where(public: true)
  end

  def self.private
    where(public: false)
  end

  def event_name
    [event_scope, event_action].join("::")
  end
end
