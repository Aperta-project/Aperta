module TahiStandardTasks
  class ProductionMetadataTask < Task

    register_task default_title: 'Production Metadata', default_role: 'admin'

    validate :publication_date, :volume_number, :issue_number, if: :newly_complete?

    def self.nested_questions
      questions = []

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "publication_date",
        value_type: "text",
        text: "Publication Date",
        position: 1
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "volume_number",
        value_type: "text",
        text: "Volume Number",
        position: 2
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "issue_number",
        value_type: "text",
        text: "Issue Number",
        position: 3
      )

      questions << NestedQuestion.new(
        owner_id:nil,
        owner_type: name,
        ident: "production_notes",
        value_type: "text",
        text: "Production Notes",
        position: 4
      )

      questions.each do |q|
        unless NestedQuestion.where(owner_id:nil, owner_type:name, ident:q.ident).exists?
          q.save!
        end
      end

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
