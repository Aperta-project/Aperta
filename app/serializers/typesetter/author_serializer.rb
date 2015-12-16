module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class AuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :first_name, :last_name, :middle_initial, :email, :department,
               :title, :corresponding, :deceased, :affiliation,
               :secondary_affiliation, :contributions

    private

    def deceased
      object.answer_for('author--deceased').try(:value)
    end

    def corresponding
      object.answer_for('author--published_as_corresponding_author').try(:value)
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
