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

class AffiliationDateValidator < ActiveModel::Validator
  attr_reader :record

  def validate(record)
    @record = record

    populate_end_date_start_date_errors
    populate_start_date_error
    populate_end_date_error
  end

  private

  def populate_end_date_start_date_errors
    %i(end_date start_date).each do |attr|
      record.errors[attr] << "must be a valid date" if invalid_date_for?(attr)
    end
  end

  def populate_start_date_error
    record.errors[:start_date] << "must be provided if end date is present" if only_end_date?
  end

  def populate_end_date_error
    record.errors[:end_date] << "must be after start date" if both_dates? && end_date_before_start_date?
  end

  def only_end_date?
    record.end_date.present? && record.start_date.blank?
  end

  def end_date_before_start_date?
    record.end_date < record.start_date
  end

  def both_dates?
    record.end_date.present? && record.start_date.present?
  end

  def invalid_date_for?(attribute)
    original_date = record.read_attribute_before_type_cast(attribute)
    return false if original_date.blank?
    Timeliness.parse(original_date).blank?
  end
end
