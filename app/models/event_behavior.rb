# Defines a "behavior" which triggers an action on a certain event.

class EventBehavior < ActiveRecord::Base
  include Attributable

  validates :event_name, inclusion: { in: %w[paper_submitted] }

  self.inheritance_column = 'action'

  def self.sti_name
    name.gsub(/Behavior$/, '').underscore
  end

  def self.find_sti_class(type_name)
    "#{type_name.camelize}Behavior".constantize
  end

  belongs_to :journal

  has_attributes boolean: %w[boolean_param],
                 json: %w[json_param],
                 string: %w[string_param]

  def call(user:, paper:, task:)
    event_params = { user: user, paper: paper, task: task }
    self.class.action_class.new.call(event_params, behavior_params)
  end

  def behavior_params
    event_behavior_attributes.each_with_object({}) do |attribute, hsh|
      hsh[attribute.name] = attribute.value
    end
  end

  class << self
    attr_accessor :action_class
  end
end
