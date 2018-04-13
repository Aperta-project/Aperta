# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

# When we update an Author, it may update the positions of all Authors
# and GroupAuthors on the paper. This serializer serializes all of
# them so those updated positions make it back to the front-end.
class PaperAuthorSerializer < AuthzSerializer
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
  #
  #
  # in ember: store.createRecord('author').save()
  #
  # response: {author: {id: 1, blah}}
  # response: {authors: [{id: 1, blah}, {id: 2, position: 2}]}
  def authors
    object.authors.reorder(id: :desc)
  end

  def group_authors
    object.group_authors.reorder(id: :desc)
  end
end
