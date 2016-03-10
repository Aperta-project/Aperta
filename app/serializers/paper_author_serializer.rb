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

  # Hokay let's talk about ordering. Ember data makes a POST to create
  # a new author (or group author). In response, it expects to see one
  # Author, or one GroupAuthor, because that's what it requested. But
  # We know that the *position* of every other author on the paper may
  # be changed at the insertion of a single new author. So we send
  # back the whole list of authors. This makes sense. But Ember Data,
  # because it is expecting one (only one) NEW author, it takes the
  # first thing we send it and inserts it, and then upserts the rest.
  # In order to make sure it INSERTS the NEW record, we order so that
  # the highest ID is first. This is sloppy and confusing, and we
  # apologize. Sam and Jerry <sam@mutuallyhuman.com>
  # <jerry@mutuallyhuman.com>
  def authors
    object.authors.order('id DESC')
  end

  def group_authors
    object.group_authors.order('id DESC')
  end
end
