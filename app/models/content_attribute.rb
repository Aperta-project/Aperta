class ContentAttribute < ActiveRecord::Base
  belongs_to :card_content, inverse_of: :content_attributes
  validates :name, presence: true, uniqueness: { scope: :card_content }

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
