module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    validate :volume_number, :issue_number, if: :newly_complete?

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

    def volume_number
      positive_integer?(:volume_number)
    end

    def issue_number
      positive_integer?(:issue_number)
    end

    private

    def positive_integer?(ident)
      answer = answer_for(ident.to_s)
      if answer.blank? || answer.value !~ /^\d+$/
        errors.add(ident, "Must be a whole number")
      end
    end
  end
end
