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

# coding: utf-8
require "rails_helper"

describe RelatedArticleSerializer do
  subject(:serializer) { described_class.new(article) }
  let(:article) { FactoryGirl.build(:related_article) }

  describe "#as_json" do
    it "serializes the related_article's properties" do
      expect(serializer.as_json).to include(:related_article)
      expect(serializer.as_json[:related_article])
        .to eq(
          id: article.id,
          additional_info: article.additional_info,
          linked_doi: article.linked_doi,
          linked_title: article.linked_title,
          paper_id: article.paper_id,
          send_link_to_apex: article.send_link_to_apex,
          send_manuscripts_together: article.send_manuscripts_together)
    end
  end
end
