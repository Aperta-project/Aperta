module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    validate :publication_date, :volume_number, :issue_number, if: :newly_complete?

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

    def publication_date
      question = a_question('publicationDate')
      errors.add(:publicationDate, "Can't be blank") unless question && question.answer
    end

    def volume_number
      positive_integer?(:volumeNumber)
    end

    def issue_number
      positive_integer?(:issueNumber)
    end

    private

    def positive_integer?(question_name)
      question = a_question(question_name.to_s)
      if not (question && /^\d+$/ =~ question.answer)
        errors.add(question_name, "Must be a whole number")
      end
    end

    def a_question(type)
      questions.detect { |q| q.ident == "production_metadata.#{type}" }
    end
  end
end
