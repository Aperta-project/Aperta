module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class AuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :type, :first_name, :last_name, :middle_initial, :email,
               :department, :title, :corresponding, :deceased, :affiliation,
               :secondary_affiliation, :contributions, :government_employee

    private

    def type
      "author"
    end

    def deceased
      object.answer_for('author--deceased').try(:value)
    end

    def corresponding
      object.paper.corresponding_author_emails.include?(object.email)
    end

    def government_employee
      object.answer_for(::Author::GOVERNMENT_EMPLOYEE_QUESTION_IDENT)
        .try(:value)
    end

    def contributions
      object.contributions.map do |contribution|
        if contribution.value_type == 'boolean'
          contribution.nested_question.text if contribution.value
        elsif contribution.value_type == 'text'
          contribution.value
        else
          fail TypeSetter::MetadataError,
               "Unknown contribution type #{contribution.value_type}"
        end
      end.compact
    end
  end
end
