# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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

  def ready?
    valid?(:ready)
  end

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
    def validate_each(obj, _attr, _value)
      obj.ready_init
      obj.card_content.card_content_validations.each do |validation|
        obj.add_errors(validation, _attr) unless validation.validate_answer(obj)
      end
      obj.errors.each { |_error, message| obj.ready_issues << message }
    end

    private

    def valid_object?(record, parent_validation_context)
      (record.respond_to?(:marked_for_destruction?) &&
        record.marked_for_destruction?) ||
        valid_with_context?(record, parent_validation_context)
    end

    def valid_with_context?(record, parent_validation_context)
      unless [:create, :update].include?(parent_validation_context)
        validation_context = parent_validation_context
      end
      record.valid?(validation_context)
    end
  end
end
