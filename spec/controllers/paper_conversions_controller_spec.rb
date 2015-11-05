require 'rails_helper'

describe PaperConversionsController, type: :controller do

  let(:paper) { create(:paper) }
  let(:job_id) { 'd5ee706f-a473-46ed-9777-3b7cd2905d08' }
  let(:user) { create :user, :site_admin }
  before { sign_in user }

  describe "GET #export" do

    context "as a user with access to a paper" do

      it "returns a job_id" do
        VCR.use_cassette('convert_to_docx') do
          get :export, id: paper.id, format: 'docx'
        end
        expect(response.status).to eq(202)
        expect(res_body['id']).to eq job_id
      end
    end

    context "as a user with no access" do
      let(:user) { create :user }
      it "returns a 403" do
        get :export, id: paper.id, format: 'docx'
        expect(response.status).to eq(403)
      end
    end
  end

  describe "GET #status" do
    it "returns job status" do
      VCR.use_cassette('check_docx_status') do
        get :status, id: job_id
        expect(response.status).to eq 200
        expect(res_body['jobs']['state']).to eq 'pending'
      end
    end
  end
end
