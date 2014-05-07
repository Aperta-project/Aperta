class AffiliationDateValidator < ActiveModel::Validator
  def validate(record)
    %i{end_date start_date}.each do |attr|
      if !valid_date_for?(record, attr)
        record.errors[attr] << "must be a valid date"
      end
    end

    if record.end_date.present? && record.start_date.blank?
      record.errors[:start_date] << "must provide an start date if end date is present"
    end

    if has_both_dates?(record) && record.end_date < record.start_date
      record.errors[:end_date] << "must be after start date"
    end
  end

  private
  def has_both_dates?(record)
    record.end_date.present? && record.start_date.present?
  end

  def valid_date_for?(record, attribute)
    original_date = record.read_attribute_before_type_cast(attribute)
    return true if original_date.blank?
    Timeliness.parse(original_date).present?
  end
end
