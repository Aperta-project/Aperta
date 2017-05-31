# This module deals with a rather specific type of validation state we need
# to support in the new Card Config world.  'Ready' is a state that is
# meant to represent whether or not an answer has any validation related issues.
# We need to do this separate from the standard Rails validations
# because we want to allow our users to save invalid data, but still
# know whether to show errors and whether or not a user is allowed
# to complete a task
module Readyable
  extend ActiveSupport::Concern
  include ActiveModel::Validations::HelperMethods

  # Associated validation that passes down context
  # See https://github.com/rails/rails/pull/24135
  class ValueValidator < ActiveModel::EachValidator #:nodoc:
    def validate_each(answer, _attribute, _value)
      if answer.kind_of? QuestionAttachment
      binding.pry
        answer.owner.card_content.card_content_validations.each do |ccv|
          if !ccv.validate_answer(answer)
            answer.errors.add(:value, ccv.validation_type.underscore.to_sym, message: ccv.error_message)
          end
        end
      else
      binding.pry

        answer.card_content.card_content_validations.each do |ccv|
          if !ccv.validate_answer(answer)
            answer.errors.add(:value, ccv.validation_type.underscore.to_sym, message: ccv.error_message)
          end
        end
      end
    end

    private

    def valid_object?(record, parent_validation_context)
      (record.respond_to?(:marked_for_destruction?) && record.marked_for_destruction?) || valid_with_context?(record, parent_validation_context)
    end

    def valid_with_context?(record, parent_validation_context)
      unless [:create, :update].include?(parent_validation_context)
        validation_context = parent_validation_context
      end
      record.valid?(validation_context)
    end
  end

  attr_accessor :ready_issues

  # Check if this thing is "ready" (for submission, for completion, for
  # registration)
  #
  # Returns true if the thing is ready, false otherwise
  # Sets the ready_issues attribute to errors if there were errors.
  def ready?
    if @ready_issues.present?
      false
    elsif valid?(:ready)
      binding.pry
      true
    else
      @ready_issues = errors.dup
      errors.clear
      false
    end
  end
end
