module Typesetter
  # Serializes a RelatedArticle for the typesetter.
  class RelatedArticleSerializer < ActiveModel::Serializer
    attributes :linked_title, :linked_doi
  end
end
