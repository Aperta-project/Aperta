require 'rails_helper'

describe TikaParser do
  describe '.parse' do
    let(:filename) { Rails.root.join('spec/fixtures/about_turtles.docx') }
    let(:paper_title) { 'This is a Title About Turtles' }
    let(:paper_body) do
      "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
    end

    subject { TikaParser.parse filename }

    its([:title]) { should eq paper_title }
    its([:body]) { should eq paper_body }

    describe "body" do
      let :original_body do
        "<p><br /></p><h1 class=\"title\">Title here</h1><h2 class=\"subtitle\">Subtitle</h2>\n<p/>\n<p>Turtles.</p>\n<p/>\n<p><a name=\"_GoBack\"></a>The end.</p>\n<p/>\n<p/>"
      end
      let :expected_body do
        "<h2 class=\"subtitle\">Subtitle</h2><p>Turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
      end

      let(:document) { TikaParser.new filename }
      let(:body) { document.body }

      before { allow(document).to receive(:output).and_return(original_body) }

      it "doesn't contain empty <p> tags" do
        expect(body).to eq expected_body
      end
    end
  end
end
