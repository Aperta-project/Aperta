module Typesetter
  # Serializes author for the typesetter.
  # Expects an author as its object to serialize.
  class AuthorSerializer < ActiveModel::Serializer
    attributes :first_name, :last_name, :middle_initial, :email, :department,
               :title, :corresponding, :deceased, :affiliation,
               :secondary_affiliation, :contributions

    private

    def contributions
      object.contributions.map do |contribution|
        break unless contribution
        contribution.nested_question.text if contribution.value
      end.compact
    end
  end
end
