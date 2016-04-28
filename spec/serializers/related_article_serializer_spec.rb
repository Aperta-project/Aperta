# coding: utf-8
require "rails_helper"

describe RelatedArticleSerializer do
  subject(:serializer) { described_class.new(article) }
  let(:article) { FactoryGirl.build(:related_article) }

  describe "#as_json" do
    it "serializes the related_article's properties" do
      expect(serializer.as_json).to include(:related_article)
      expect(serializer.as_json[:related_article])
        .to include(
          additional_info: article.additional_info,
          linked_doi: article.linked_doi,
          linked_title: article.linked_title,
          paper_id: article.paper_id,
          send_link_to_apex: article.send_link_to_apex,
          send_manuscripts_together: article.send_manuscripts_together)
    end
  end
end
