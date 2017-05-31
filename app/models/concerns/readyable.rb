# Module to include
module Readyable
  extend ActiveSupport::Concern
  include ActiveModel::Validations::HelperMethods

  # Associated validation that passes down context
  # See https://github.com/rails/rails/pull/24135
  class ValueValidator < ActiveModel::EachValidator #:nodoc:
    def validate_each(answer, _attribute, _value)
      answer.card_content.card_content_validations.each do |ccv|
        if !ccv.validate_answer(answer)
          answer.errors.add(:value, ccv.validation_type.underscore.to_sym, message: ccv.error_message)
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
      true
    else
      @ready_issues = errors.dup
      errors.clear
      false
    end
  end
end
