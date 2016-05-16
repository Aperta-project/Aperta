module Typesetter
  # Serializes authors and group authors for the typesetter.
  # Expects an authors task as its object to serialize.
  class AuthorListItemSerializer < Typesetter::TaskAnswerSerializer
    has_one :author

    def author
      serializer = "Typesetter::#{object.author_type}Serializer".constantize
      serializer.new(object.author)
    end
  end
end
