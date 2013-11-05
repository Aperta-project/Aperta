require 'spec_helper'

describe DocumentParser do

  describe '.parse' do
    let(:filename) { Rails.root.join('spec/fixtures/about_turtles.docx') }
    let(:paper_title) { 'This is a Title About Turtles' }
    let(:paper_body) do
      "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2>\n<p></p>\n<p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p>\n<p></p>\n<p><a name=\"_GoBack\"></a>The end.</p>\n<p></p>\n<p></p>"
    end

    subject { DocumentParser.parse filename }

    its([:title]) { should eq paper_title }
    its([:body]) { should eq paper_body }
  end
end
