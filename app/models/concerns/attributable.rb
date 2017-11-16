# rubocop:disable Style/PredicateName
# rubocop:disable Metrics/AbcSize
#
# This concern enables the entity part of an EAV model
# (https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)
#
# See CardContent model for an example of its use.
# See EntityAttribute for the attributes.
module Attributable
  extend ActiveSupport::Concern

  included do
    has_many :entity_attributes, dependent: :destroy, inverse_of: :entity, as: :entity
  end

  module ClassMethods
    def has_attributes(types)
      types.each do |type, names|
        names.each do |name|
          getter = "#{name}_attribute".to_sym
          setter = "#{name}_attribute=".to_sym

          has_one getter, -> { where(name: name) }, class_name: EntityAttribute, as: :entity

          define_method(name) do
            if send(:entity_attributes).loaded?
              send(:entity_attributes).find { |a| a.name == name }.try(:value)
            else
              send(getter).try(:value)
            end
          end

          define_method("#{name}=") do |new_value|
            content_attribute = send(getter) || send(:entity_attributes).new(name: name, value_type: type)
            content_attribute.value = new_value.presence
            send(setter, content_attribute)
          end
        end
      end
    end
  end
end
