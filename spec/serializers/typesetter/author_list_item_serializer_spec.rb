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

describe Typesetter::AuthorListItemSerializer do
  subject(:serializer) { described_class.new(author_list_item, options) }
  let(:author_list_item) do
    FactoryGirl.build(:author_list_item, author: author)
  end
  let(:author) { FactoryGirl.build(:author) }
  let(:group_author) { FactoryGirl.build(:group_author) }

  let(:output) { serializer.serializable_hash }
  let!(:apex_html_flag) { FactoryGirl.create :feature_flag, name: "KEEP_APEX_HTML", active: false }
  let!(:options) { { destination: "em", unique_values: {} } }

  describe 'author' do
    it 'includes the author' do
      expect(output[:author]).to be
    end

    it <<-DESC.strip_heredoc do
      serializes the author by looking a serializer based on the author's
      type since it is polymorphic
    DESC
      author_list_item.author = Author.new
      expect(Typesetter::AuthorSerializer).to receive(:new)
        .with(author_list_item.author, options)
      serializer.serializable_hash

      author_list_item.author = GroupAuthor.new
      expect(Typesetter::GroupAuthorSerializer).to receive(:new)
        .with(author_list_item.author, options)
      serializer.serializable_hash
    end
  end
end
