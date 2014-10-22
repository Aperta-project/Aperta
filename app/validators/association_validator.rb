class AssociationValidator < ActiveModel::Validator
  def validate(record)
    record.errors[association].clear # remove generic "is invalid" messages

    errors = record.send(association).each_with_object({}) do |associated, errors|
      if associated.invalid?
        errors[associated.id] = associated.errors
      end
    end

    if errors.any?
      record.errors.set(association, errors)
      record.send(failure_callback) if failure_callback.present?
    end

    errors.empty?
  end


  private

  def association
    options[:association]
  end

  def failure_callback
    options[:fail]
  end
end
