require 'rails_helper'

describe PaperConverter do
  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator)
  end
  let(:user) { FactoryGirl.create(:user) }

  describe ".export" do
    it "returns job_id" do
      VCR.use_cassette('convert_to_docx', record: :once) do
        response = described_class.export(paper, 'docx', user)
        expect(response.job_id).to eq 'd5ee706f-a473-46ed-9777-3b7cd2905d08'
      end
    end
  end
end
