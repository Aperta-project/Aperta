module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    validate :publication_date, :volume_number, :issue_number, if: :task_completed?

    def active_model_serializer
      ProductionMetadataTaskSerializer
    end

    def publication_date
      question = a_question('publicationDate')
      errors.add(:publicationDate, "Can't be blank") unless question && question.answer
    end

    def volume_number
      question = a_question('volumeNumber')
      errors.add(:volumeNumber, "Invalid Volume Number") unless question && question.answer.to_i > 0
    end

    def issue_number
      question = a_question('issueNumber')
      errors.add(:issueNumber, "Invalid Issue Number") unless question && question.answer.to_i > 0
    end

    private

    def task_completed?
      self.completed?
    end

    def a_question(type)
      questions.detect { |q| q.ident == "production_metadata.#{type}" }
    end
  end
end
