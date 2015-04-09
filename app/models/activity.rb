class Activity < ActiveRecord::Base
  belongs_to :target, polymorphic: true
  belongs_to :actor, class_name: "User"
  belongs_to :scope, polymorphic: true

  validates :actor, :scope, :target, :event_name, :region_name, presence: true

  def self.public
    where(public: true)
  end

  def self.private
    where(public: false)
  end

  def self.with_event_names(event_names)
    where(event_name: event_names)
  end

  def self.for_target(target)
    return where(nil) unless target
    where(target: target)
  end

  def self.without(activities)
    where.not(id: activities.flat_map(&:id))
  end
end
