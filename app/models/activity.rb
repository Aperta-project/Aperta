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
end
