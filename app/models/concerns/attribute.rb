# rubocop:disable Style/PredicateName
module Attribute
  extend ActiveSupport::Concern

  module ClassMethods
    def is_attribute_of(relation_name, inverse_of:)
      belongs_to relation_name, inverse_of: inverse_of
      validates :name, presence: true, uniqueness: { scope: relation_name }
    end
  end

  included do
    def value
      case value_type
      when 'string'  then string_value
      when 'boolean' then boolean_value?
      when 'integer' then integer_value
      when 'json'    then json_value
      end
    end

    def value=(content)
      case value_type
      when 'string'  then self.string_value  = content
      when 'boolean' then self.boolean_value = content
      when 'integer' then self.integer_value = content
      when 'json'    then self.json_value    = content
      end
    end
  end
end
