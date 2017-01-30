class NestedQuestionAnswer < ActiveRecord::Base
  include Readyable

  SUPPORTED_VALUE_TYPES = ::NestedQuestion::SUPPORTED_VALUE_TYPES

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

  validate :verify_from_owner

  has_one :parent_nested_question,
    through: :nested_question,
    source: :parent,
    class_name: 'NestedQuestion'

  # Readyable stuff
  validates :value_raw,
            on: :ready,
            presence: true,
            if: -> {
    if nested_question.ready_required_check == 'required'
      true
    elsif nested_question.ready_required_check == 'if_parent_yes'
      parent.try(:yes_no_value) == NestedQuestionAnswer::YES
    end
  }

  validates :yes_no_value,
            on: :ready,
            if: -> { nested_question.ready_required_check == 'required' },
            inclusion: { in: [YES, NO] }

  # If you add a validation class here, be sure to add it to
  # NestedQuestion::READY_CHECK_TYPES
  validates :yes_no_value,
            on: :ready,
            if: -> { nested_question.ready_check == 'yes' },
            inclusion: { in: [YES] }

  validates :yes_no_value,
            on: :ready,
            if: -> { nested_question.ready_check == 'no' },
            inclusion: { in: [NO] }

  validates :value_raw,
            on: :ready,
            length: { minimum: 20 },
            if: -> { nested_question.ready_check == 'long_string' }

  validate do
    if changed? && decision.present? && decision.completed?
      errors.add(:base, 'Cannot modify an answer for a registered decision.')
    end
  end

  def nested_question_parent
    nested_question.parent
  end

  def parent
    NestedQuestionAnswer.find_by(nested_question: parent_nested_question, owner: owner)
  end

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

  def value_raw
    self[:value]
  end

  def verify_from_owner
    return if disable_owner_verification
    return unless owner.respond_to?(:can_change?)
    unless owner.can_change?(self)
      errors.add :answer, "can't change answer"
    end
  end

  def attachment_value_type
    value_raw
  end

  def boolean_value_type
    return nil if value_raw.nil?
    value_raw.match(TRUTHY_VALUES_RGX) ? true : false
  end

  def text_value_type
    value_raw
  end

  def question_set_value_type
    value_raw
  end
end
