module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    validate :publication_date, :volume_number, :issue_number, if: :newly_complete?

    def self.nested_questions
      NestedQuestion.where(owner_id:nil, owner_type:name).all
    end

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

    def publication_date
      answer = answer_for("publication_date")
      errors.add(:publication_date, "Can't be blank") unless answer
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
