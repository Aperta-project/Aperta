require 'spec_helper'

describe DocumentParser do

  describe '.parse' do
    let(:filename) { '/path/to/file' }
    let(:paper_title) { 'Paper Title' }
    let(:paper_body) do
      <<-TEXT.strip_heredoc
        Paper subtitle

        This is the body of the paper.

        This is the next paragraph.

        In conclusion, the Teenage Mutant Ninja Turtles rock!
      TEXT
    end

    before do
      paper_text = "#{paper_title}\n#{paper_body}"
      Open3.stub(:capture3).and_return [paper_text, nil, nil]
    end

    subject { DocumentParser.parse filename }

    its([:title]) { should eq paper_title }
    its([:body]) { should eq paper_body }
  end
end
