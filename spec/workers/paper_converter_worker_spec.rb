require 'spec_helper'

describe PaperConverterWorker do

  let(:paper) { FactoryGirl.create(:paper) }
  let(:user) { FactoryGirl.create(:user) }

  describe ".export" do
    it "returns job_id" do
      VCR.use_cassette('convert_to_docx', record: :once) do
        job_id = JSON.parse(described_class.export(paper, 'docx', user))['jobs']['id']
        expect(job_id).to eq 'd5ee706f-a473-46ed-9777-3b7cd2905d08'
      end
    end
  end
end
