require 'spec_helper'

describe EpubConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:paper) do
    FactoryGirl.create :paper, body: paper_body, short_title: paper_title, user: FactoryGirl.create(:user)
  end

  describe '#generate_epub' do
    it 'returns a stream of data to the controller' do
      epub = EpubConverter.generate_epub(paper)
      expect(epub[:stream]).to be_a StringIO
      expect(epub[:file_name]).to end_with '.epub'
    end

    context 'empty paper body' do
      let(:paper) do
        FactoryGirl.create :paper, body: nil, short_title: 'Paper with no body', user: FactoryGirl.create(:user)
      end

      it 'returns paper body with default text' do
        expect{ EpubConverter.generate_epub(paper) }.to_not raise_error
      end
    end
  end
end
