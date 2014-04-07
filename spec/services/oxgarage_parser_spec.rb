require 'spec_helper'

describe OxgarageParser, vcr: {cassette_name: 'oxgrage_parser'} do
  describe '.parse' do
    let(:filename) { Rails.root.join('spec/fixtures/about_turtles.docx') }
    let(:paper_title) { 'This is a Title About Turtles' }
    let(:paper_body) do
      "<p class=\"Subtitle\">And this is my subtitle about how turtles are awesome</p>\n<p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p>\n<p>The end.</p>\n<div class=\"stdfooter\">\n<div class=\"footer\">\n<!--standard links to project, instiution etc--><a class=\"plain\" href=\"/\">Home</a> </div>\n<address>David Bland.\n\t    Date: 2013-10-29<br><!--\n\t  Generated from index.xml using XSLT stylesheets version 7.11.0\n\n\t       based on http://www.tei-c.org/Stylesheets/\n\t       on 2014-04-07T17:55:27Z.\n\t       SAXON HE 9.4.0.3.\n\t\t -->\n</address>\n</div>"
    end

    subject { OxgarageParser.parse filename }

    its([:title]) { should eq paper_title }
    its([:body]) { should eq paper_body }

    describe "#body" do
      let :original_body do
        "<p><br /></p><h1 class=\"title\">Title here</h1><h2 class=\"subtitle\">Subtitle</h2>\n<p/>\n<p>Turtles.</p>\n<p/>\n<p><a name=\"_GoBack\"></a>The end.</p>\n<p/>\n<p/>"
      end

      let(:expected_body) do
        "<h1 class=\"title\">Title here</h1>\n<h2 class=\"subtitle\">Subtitle</h2><p>Turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
      end

      let(:document) { OxgarageParser.new filename }
      let(:body) { document.body }

      before { allow(document).to receive(:output).and_return(original_body) }

      it "doesn't contain empty <p> tags" do
        expect(body).to eq expected_body
      end
    end
  end
end
