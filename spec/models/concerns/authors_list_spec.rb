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

require 'rails_helper'

describe TahiStandardTasks::AuthorsList do
  let!(:paper) { FactoryGirl.create :paper }
  let!(:author1) do
    FactoryGirl.create :author, paper: paper, first_name: "FirstAuthor"
  end
  let!(:author2) do
    FactoryGirl.create :author, paper: paper, first_name: "SecondAuthor"
  end

  before do
    author1.position = 1
    author2.position = 2
    author1.save
    author2.save
  end

  # rubocop:disable LineLength
  it "returns ordered list of authors last and first name, and affiliation" do
    expect(subject.authors_list(paper)).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name} from #{author2.affiliation}"
  end

  it "only includes `from $affiliation` when author has an affiliation" do
    author2.update_attributes(affiliation: nil)
    expect(subject.authors_list(paper)).to eq "1. #{author1.last_name}, #{author1.first_name} from #{author1.affiliation}\n2. #{author2.last_name}, #{author2.first_name}"
  end
  # rubocop:enable LineLength
end
