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
    def validate_each(obj, _attribute, _value)
      validation_owner = obj.kind_of?(QuestionAttachment) ? obj.owner : obj
      validate_from_card_content(validation_owner, obj, _attribute)
    end

    private

    def validate_from_card_content(validation_owner, object, attribute)
      object.ready = true
      validation_owner.card_content.card_content_validations.each do |ccv|
        unless ccv.validate_answer(object)
          # setting ready and ready_issues for serializer consumption
          object.ready = false
          object.ready_issues = []
          object.errors.add(attribute,
                            ccv.validation_type.underscore.to_sym,
                            message: ccv.error_message)
          object.errors.each { |error, message| object.ready_issues << message }
        end
      end
    end

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
  attr_accessor :ready
end
