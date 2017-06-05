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

  def ready_init
    self.ready = true
    self.ready_issues = []
  end

  def add_errors(ccv, attribute)
    self.ready = false
    self.errors.add(attribute,
                      ccv.validation_type.underscore.to_sym,
                      message: ccv.error_message)
  end

  attr_accessor :ready_issues
  attr_accessor :ready

  # Associated validation that passes down context
  # See https://github.com/rails/rails/pull/24135
  class ValueValidator < ActiveModel::EachValidator #:nodoc:
    def validate_each(obj, _attribute, _value)
      obj.ready_init
      validation_owner = obj.kind_of?(QuestionAttachment) ? obj.owner : obj
      validation_owner.card_content.card_content_validations.each do |ccv|
        obj.add_errors(ccv, _attribute) unless ccv.validate_answer(obj)
      end
      obj.errors.each { |error, message| obj.ready_issues << message }
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

end
