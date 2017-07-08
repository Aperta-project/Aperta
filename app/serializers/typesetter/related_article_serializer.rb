module Typesetter
  # Serializes a RelatedArticle for the typesetter.
  class RelatedArticleSerializer < ActiveModel::Serializer
    attributes :linked_title, :linked_doi

    def linked_title
      strip_tags(object.linked_title)
    end
  end
end
