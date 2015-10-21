require 'rails_helper'

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
    let(:doc) { Nokogiri::HTML(pdf_html) }
    let(:body) { PaperDownloader.new(paper).body }
    let(:pdf_html) { PDFConverter.pdf_html paper, presenter, body }
    let(:presenter) { PublishingInformationPresenter.new paper, user }

    after { expect(doc.errors.length).to be 0 }

    it "includes all necessary info and default journal stylesheet in the generated HTML" do
      expect(pdf_html).to include journal.pdf_css
      expect(pdf_html).to include paper.display_title(sanitized: false)
      expect(pdf_html).to include paper.body
    end

    it "displays HTML in the paper's title" do
      paper.title = "This <i>is</i> the Title"
      expect(doc).to have_path("#paper-body h1:contains('#{paper.display_title}')")
    end
  end
end
