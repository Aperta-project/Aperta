require 'spec_helper'

describe PaperConversionsController, type: :controller do
  let(:user) { create :user, :site_admin }

  let(:paper) do
    create(:paper, user: user, body: "This is the body")
  end
  let(:job_id) { 'd5ee706f-a473-46ed-9777-3b7cd2905d08' }

  before { sign_in user }

  describe "GET #export" do
    it "returns a job_id" do
      VCR.use_cassette('convert_to_docx') do
        get :export, id: paper.id, export_format: 'docx'
      end
      expect(response.status).to eq(203)
      response_hash = JSON.parse(response.body)
      expect(response_hash['jobs']['id']).to eq job_id
    end
  end

  describe "GET #status" do
    it "returns job status" do
      VCR.use_cassette('check_docx_status') do
        get :status, id: job_id
        expect(response.status).to eq 200
        json_response = JSON.parse(response.body)
        expect(json_response['jobs']['status']).to eq "pending"
      end
    end
  end
end
