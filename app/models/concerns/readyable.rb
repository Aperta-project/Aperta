# Module to include
module Readyable
  extend ActiveSupport::Concern
  include ActiveModel::Validations::HelperMethods

  # Associated validation that passes down context
  # See https://github.com/rails/rails/pull/24135
  class AssociatedValidatorWithContext < ActiveModel::EachValidator #:nodoc:
    def validate_each(record, attribute, value)
      if Array(value).reject { |r| valid_object?(r, record.validation_context) }.any?
        record.errors.add(attribute, :invalid, options.merge(value: value))
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

  included do
    def self.validates_associated_with_context(*attr_names)
      validates_with AssociatedValidatorWithContext, _merge_attributes(attr_names)
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
