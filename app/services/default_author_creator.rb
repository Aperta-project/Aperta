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

class DefaultAuthorCreator

  attr_reader :creator, :paper, :author

  def initialize(paper, creator)
    @paper = paper
    @creator = creator
  end

  def create!
    build_author
    add_affiliation_information
    author.save!
    author
  end

  private

  def build_author
    @author = Author.create(
      first_name: creator.first_name,
      last_name: creator.last_name,
      email: creator.email,
      paper: paper,
      user: creator
    )
  end

  def add_affiliation_information
    if creator_affiliation = creator.affiliations.by_date.first
      author.affiliation = creator_affiliation.name
      author.department = creator_affiliation.department
      author.title = creator_affiliation.title
    end
  end
end
