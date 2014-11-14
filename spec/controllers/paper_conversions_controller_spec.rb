require 'spec_helper'

describe PaperConversionsController, :type => :controller do
  let(:user) { create :user, :site_admin }

  let(:paper) do
    create(:paper, user: user, body: "This is the body")
  end

  before { sign_in user }

  describe "GET #export" do
    it "returns a job_id" do
      VCR.use_cassette('convert_to_docx') do
        get :export, id: paper.id, export_format: 'docx'
      end
      expect(response.status).to eq(203)
      expect(JSON.parse response.body).to eq("job_id" => "f1bbf4b3-70c3-4e92-bae8-a7a2d99715bf")
    end
  end
end
