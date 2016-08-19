class NestedQuestionAnswer < ActiveRecord::Base
  SUPPORTED_VALUE_TYPES = ::NestedQuestion::SUPPORTED_VALUE_TYPES
  VALUE_REQUIRED_FOR_TYPES = ::NestedQuestion::VALUE_REQUIRED_FOR_TYPES

  TRUTHY_VALUES_RGX = /^(t|true|y|yes|1)/i
  YES = "Yes"
  NO = "No"

  class_attribute :disable_owner_verification
  acts_as_paranoid

  belongs_to :paper
  belongs_to :decision
  belongs_to :nested_question,
    inverse_of: :nested_question_answers,
    class_name: 'NestedQuestion', foreign_key: 'nested_question_id',
    with_deleted: true
  belongs_to :owner, polymorphic: true
  has_many :attachments, -> { order('id ASC') }, dependent: :destroy, as: :owner, class_name: 'QuestionAttachment'

  validates :value_type, presence: true, inclusion: { in: SUPPORTED_VALUE_TYPES }
  validates :value, presence: true, if: :value_is_required?

  validate :verify_from_owner

  def self.find_or_build(nested_question:, decision: nil, value: nil)
    query_params = { nested_question_id: nested_question.id }
    query_params[:decision_id] = decision.id if decision
    where(query_params).first_or_initialize(
      value_type: nested_question.value_type,
      value: value,
      decision: decision
    )
  end

  def task
    if owner.is_a?(Task)
      owner
    elsif owner.respond_to?(:task)
      owner.task
    else
      fail NotImplementedError, <<-ERROR.strip_heredoc
        The owner (#{owner.inspect}) does is not a Task and does not respond to
        #task. This is currently unsupported on #{self.class.name} and if you
        meant it to work you may need to update the implementation.
      ERROR
    end
  end

  def value
    return nil unless value_type.present?
    read_value_method = "#{value_type.underscore}_value_type".to_sym

    return unless respond_to?(read_value_method, true)
    send read_value_method
  end

  def float_value
    value.to_f
  end

  def yes_no_value
    return nil if value.nil?
    return YES if value
    NO
  end

  private

  def value_is_required?
    VALUE_REQUIRED_FOR_TYPES.include?(value_type) && value.nil?
  end

  def verify_from_owner
    return if disable_owner_verification
    return unless owner.respond_to?(:can_change?)
    unless owner.can_change?(self)
      errors.add :answer, "can't change answer"
    end
  end

  def attachment_value_type
    self[:value]
  end

  def boolean_value_type
    return nil if self[:value].nil?
    self[:value].match(TRUTHY_VALUES_RGX) ? true : false
  end

  def text_value_type
    self[:value]
  end

  def question_set_value_type
    self[:value]
  end
end
