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

# This creates the json representation of individual authors for use in
# versioning and diffing. Triggered on the paper submitted event.
class Snapshot::AuthorTaskSerializer < Snapshot::BaseSerializer
  private

  def snapshot_properties
    authors = model.authors
              .includes(:author_list_item)
              .map do |author|
      Snapshot::AuthorSerializer.new(author).as_json
    end

    group_authors = model.group_authors
                    .includes(:author_list_item)
                    .map do |author|
      Snapshot::GroupAuthorSerializer.new(author).as_json
    end

    (authors + group_authors).sort_by { |a| a[:position] }
  end
end
