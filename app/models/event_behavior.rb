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

  def self.action_class(klass) # rubocop:disable Style/TrivialAccessors
    @action_class = klass
  end

  has_attributes :event_behavior_attributes,
                 inverse_of: :event_behavior,
                 types: {
                   boolean: %w[boolean_param],
                   json: %w[json_param],
                   string: %w[string_param letter_template]
                 }

  def call(user:, paper:, task:)
    @action_klass.new.call(parameters, event_data)
  end

  def parameters
    event_behavior_attributes.each_with_object({}) do |attribute, hsh|
      hsh[attribute.name] = attribute.value
    end
  end
end
