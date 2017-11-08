class EntityAttribute < ActiveRecord::Base
  include XmlSerializable

  belongs_to :entity, inverse_of: :entity_attributes, polymorphic: true
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
