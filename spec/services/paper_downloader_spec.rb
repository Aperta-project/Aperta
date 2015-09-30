require 'rails_helper'

describe PaperDownloader do

  let(:paper) { FactoryGirl.create :paper }

  describe "#body" do

    let(:body) { PaperDownloader.new(paper).body }
    let(:doc) { Nokogiri::HTML(body) }

    context "Manuscript content" do

      it "returns content of the latest versioned text" do
        expect(body).to eq(paper.latest_version.text)
      end

      it "returns the content of inline figures redirected to s3" do
        figure = paper.figures.create! attachment: tiff_file
        # Let's assume that this is valid html content
        html_with_url = "src='/attachments/figures/#{figure.id}?version=detail'"
        paper.latest_version.update(text: html_with_url)

        expect(body).to match(/'https:\/\/tahi.+detail_yeti.png\?X-Amz-Expires/)
      end
    end

    context "Supporting Information Files information" do

      it "does not have supporting information section" do
        expect(paper.supporting_information_files.count).to eq(0)
        expect(body).not_to include("<h2>Supporting Information</h2>")
      end

      it "returns an h2 tag with the title 'Supporting Information'" do
        with_aws_cassette 'supporting_info_files_controller' do
          paper.supporting_information_files.create! attachment: tiff_file
        end
        expect(body).to include("<h2>Supporting Information</h2>")
      end

      it "has image preview and link with image" do
        with_aws_cassette 'supporting_info_files_controller' do
          paper.supporting_information_files.create! attachment: tiff_file
        end
        expect(doc.search('a:contains("yeti.tiff")').length).to eq(1)
        expect(doc.search('img[src*="yeti.png"]').length).to eq(1)
      end

      it "has link to unsupported image attachment" do
        with_aws_cassette 'supporting_info_files_controller_not_supported_image' do
          paper.supporting_information_files.create! attachment: bmp_file
        end
        expect(doc.search('img').length).to eq(0)
        expect(doc.search('a:contains("cat.bmp")').length).to eq(1)
        expect(doc.search('a[href*="cat.bmp"]').length).to eq(1)
      end
    end
  end

  def tiff_file
    ::File.open('spec/fixtures/yeti.tiff')
  end

  def bmp_file
    ::File.open('spec/fixtures/cat.bmp')
  end

end
