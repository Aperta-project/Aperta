module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class AuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :first_name, :last_name, :middle_initial, :email, :department,
               :title, :corresponding, :deceased, :affiliation,
               :secondary_affiliation, :contributions

    private

    def deceased
      task_answer_value(object, 'author.deceased')
    end

    def corresponding
      task_answer_value(object, 'author.published_as_corresponding_author')
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
