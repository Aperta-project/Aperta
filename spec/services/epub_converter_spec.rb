require 'spec_helper'

describe EpubConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:user) { FactoryGirl.create :user}
  let(:paper) do
    FactoryGirl.create :paper, body: paper_body, short_title: paper_title, user: user
  end

  describe '#generate_epub' do
    it 'returns an epub file path' do
      EpubConverter.generate_epub(paper, user) do |epub|
        expect(epub).to match /.epub$/
      end
    end
    it 'returns a path to the generated epub file' do
      EpubConverter.generate_epub(paper, user) do |epub|
        expect(File.exists? epub).to eq true
      end
    end
  end
end
