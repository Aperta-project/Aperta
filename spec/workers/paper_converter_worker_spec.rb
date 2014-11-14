require 'spec_helper'

describe PaperConverterWorker do

  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  describe ".export" do
    it "returns job_id" do
      VCR.use_cassette('convert_to_docx', :record => :all) do
        x = described_class.export(paper, 'docx', user)
        expect(x).to eq '51b0bf5c-bc48-47eb-bab7-c596cdcd954f'
      end
    end
  end
end
