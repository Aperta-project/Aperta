class NestedQuestionAnswer < ActiveRecord::Base
  TRUTHY_VALUES_RGX = /^(t|true|y|yes|1)/i
  SUPPORTED_VALUE_TYPES = %w(attachment boolean question-set text)

  belongs_to :decision
  belongs_to :nested_question
  belongs_to :owner, polymorphic: true
  has_one :attachment, dependent: :destroy, as: :question, class_name: "QuestionAttachment"

  validates :value_type, presence: true, inclusion: { in: SUPPORTED_VALUE_TYPES }
  validates :value, presence: true, if: -> (answer) { answer.value.nil? }

  def value
    return nil unless value_type.present?
    read_value_method = "#{value_type.underscore}_value_type".to_sym

    return unless respond_to?(read_value_method, true)
    send read_value_method
  end

  private

  def attachment_value_type
    self[:value]
  end

  def boolean_value_type
    self[:value].match(TRUTHY_VALUES_RGX) ? true : false
  end

  def text_value_type
    self[:value]
  end

  def question_set_value_type
    self[:value]
  end
end
