module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class IndividualAuthorSerializer < Typesetter::TaskAnswerSerializer
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
      if paper_has_corresponding_author?
        object.answer_for('author--published_as_corresponding_author') \
          .try(:value)
      else
        object.email == object.paper.creator.email
      end
    end

    def paper_has_corresponding_author?
      object.paper.authors.select(corresponding?: true).any?
    end

    def government_employee
      object.answer_for('author--government-employee').try(:value)
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
