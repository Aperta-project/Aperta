module Typesetter
  # Serializes authors and group authors for the typesetter.
  # Expects an authors task as its object to serialize.
  class AuthorsSerializer < Typesetter::TaskAnswerSerializer
    has_one :author_or_group_author, key: :author

    def author_or_group_author
      if object.author_type == "Author"
        Typesetter::IndividualAuthorSerializer.new(
          Author.find(object.author_id))
      else
        Typesetter::GroupAuthorSerializer.new(
          GroupAuthor.find(object.author_id))
      end
    end
  end
end
