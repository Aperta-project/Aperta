class NestedQuestionAnswer < ActiveRecord::Base
  TRUTHY_VALUES_RGX = /^(t|true|y|yes|1)/i
  SUPPORTED_VALUE_TYPES = %w(attachment boolean question-set text)

  belongs_to :nested_question
  belongs_to :owner, polymorphic: true

  validates :value_type, presence: true, inclusion: { in: SUPPORTED_VALUE_TYPES }

  def value=(arg)
    if arg.is_a?(Hash)
      write_attribute :value, arg.to_json
    else
      write_attribute :value, arg
    end
  end

  def value
    read_value_method = "#{value_type.underscore}_value_type".to_sym
    if respond_to?(read_value_method, include_private_methods=true)
      send read_value_method
    end
  end

  private

  def attachment_value_type
    raw_value = read_attribute(:value)
    JSON.parse raw_value if raw_value.present?
  end

  def boolean_value_type
    read_attribute(:value).match(TRUTHY_VALUES_RGX) ? true : false
  end

  def text_value_type
    read_attribute(:value)
  end

  def question_set_value_type
    read_attribute(:value)
  end
end
