# When we update an Author, it may update the positions of all Authors
# and GroupAuthors on the paper. This serializer serializes all of
# them so those updated positions make it back to the front-end.
class PaperAuthorSerializer < ActiveModel::Serializer
  has_many :authors,
           serializer: AuthorSerializer,
           embed: :ids,
           include: true
  has_many :group_authors,
           serializer: GroupAuthorSerializer,
           embed: :ids,
           include: true

  def authors
    object.authors.order('id DESC')
  end

  def group_authors
    object.group_authors.order('id DESC')
  end
end
