# This class provides the attribute part of an EAV model
# (https://en.wikipedia.org/wiki/Entity%E2%80%93attribute%E2%80%93value_model)
#
# It allows defining any number of named attributes (of different types)
# attached to an entity without changing the database schema. The names and
# types of the attributes are managed in code: see Attributable.
class EntityAttribute < ActiveRecord::Base
  include XmlSerializable

  # The entity to which this attribute belongs.
  belongs_to :entity, inverse_of: :entity_attributes, polymorphic: true
  # Ensure there is only a single attribute for each name on a given entity.
  validates :name, presence: true, uniqueness: { scope: :entity }

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
