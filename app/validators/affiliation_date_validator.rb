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
