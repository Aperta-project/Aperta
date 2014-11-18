require 'spec_helper'

describe PDFConverter do
  let(:paper_title) { 'This is a Title About Turtles' }
  let(:paper_body) do
    "<h2 class=\"subtitle\">And this is my subtitle about how turtles are awesome</h2><p>Turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles turtles.</p><p><a name=\"_GoBack\"></a>The end.</p>"
  end
  let(:journal) do
    create :journal, pdf_css: "body { background-color: red; }"
  end

  let(:paper) do
    create :paper, body: paper_body, short_title: paper_title, creator: create(:user), journal: journal
  end

  let(:user) { create :user }

  describe ".convert" do
    it "uses PDFKit to generate PDF" do
      expect(PDFKit).to receive_message_chain(:new, :to_pdf)
      PDFConverter.convert paper, user
    end
  end

  describe ".pdf_html" do
    it "includes all necessary info and default journal stylesheet in the generated HTML" do
      presenter = PublishingInformationPresenter.new paper, user
      pdf_html = PDFConverter.pdf_html paper, presenter
      expect(pdf_html).to include journal.pdf_css
      expect(pdf_html).to include paper.display_title
      expect(pdf_html).to include paper.body
    end
  end
end
