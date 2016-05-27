class NedValidator < ActiveModel::Validator
  def validate(record)
    return unless record.credentials.where(provider: 'cas').first

    ned_id = record.ned_id
    if ned_id.present?
      unless ned_id.integer? && (ned_id != 0) && ned_id.to_s.match(/\A[+-]?\d+\Z/)
        record.errors[:ned_id] << 'must be an integer'
      end
    else
      record.errors[:ned_id] << 'must be present'
    end
  end
end
