class NestedQuestion < ActiveRecord::Base
  acts_as_nested_set order_column: :position
  belongs_to :owner, polymorphic: true

  def value
    read_value_method = "#{value_type.underscore}_value_type".to_sym
    if respond_to?(read_value_method, include_private_methods=true)
      send read_value_method
    else
      raise NotImplementedError, "#{read_value_method} is not a known value type"
    end
  end

  private

  def boolean_value_type
    read_attribute(:value) == "true" ? true : false
  end

  def text_value_type
    read_attribute(:value)
  end

  def question_set_value_type
    read_attribute(:value)
  end

end
