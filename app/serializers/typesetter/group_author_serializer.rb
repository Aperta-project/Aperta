module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class GroupAuthorSerializer < Typesetter::TaskAnswerSerializer
    attributes :name,
               :contact_first_name, :contact_last_name, :contact_middle_name,
               :contact_email, :contributions, :position

    private

    def government_employee
      object.answer_for('group-author--government-employee').try(:value)
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
