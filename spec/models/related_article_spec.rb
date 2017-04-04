require 'rails_helper'

describe RelatedArticle do
  subject(:related_article) do
    FactoryGirl.build :related_article,
                                                linked_title: '<b>Some linked title</b>'
  end

  context 'associations' do
    it('belongs_to paper') { expect(RelatedArticle.reflect_on_association(:paper).macro).to eq :belongs_to }
  end

  describe '#strip_linked_title_html' do
    it 'strips linked_title_html tags' do
      expect(related_article.strip_linked_title_html).to eq 'Some linked title'
    end
  end
end
