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

class AssociationValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    remove_invalid_messages

    if association_errors.any?
      record.errors.set(association, association_errors)
      record.send(failure_callback) if failure_callback.present?
    end
    association_errors.empty?
  end

  private

  def association_errors
    record.send(association).each_with_object({}) { |associated, errors|
      run_before_each_validation(associated)
      errors[associated.id] = associated.errors if associated.invalid?
    }
  end

  def run_before_each_validation(associated)
    options[:before_each_validation].try(:call, @record, associated)
  end

  def association
    options[:association]
  end

  def failure_callback
    options[:fail]
  end

  def remove_invalid_messages
    record.errors[association].clear
  end
end
