require 'rails_helper'

describe SupportingInformationFilesController, redis: true do
  let!(:user) { create :user }
  let!(:paper) do
    FactoryGirl.create(:paper, creator: user)
  end

  authorize_policy(SupportingInformationFilesPolicy, true)

  before do
    sign_in user
  end

  describe "DELETE 'destroy'" do
    context "when authorized" do
      subject(:do_request) do
        delete :destroy, id: paper.supporting_information_files.last.id, paper_id: paper.id
      end
      before do
        paper.supporting_information_files.create
      end

      it "destroys the file record" do
        expect {
          do_request
        }.to change{SupportingInformationFile.count}.by -1
      end
    end
  end

  describe "POST 'create'" do
    let(:url) { "http://someawesomeurl.com" }
    it "creates the supporting file" do
      expect(DownloadSupportingInfoWorker).to receive(:perform_async)
      post :create, format: "json", paper_id: paper.to_param, url: url
      expect(response.status).to eq(201)
    end
  end

  describe "PUT 'update'" do
    subject(:do_request) { patch :update, format: :json, id: paper.supporting_information_files.last.id, paper_id: paper.id, supporting_information_file: {title: "new title", caption: "new caption"} }
    before(:each) do
      with_aws_cassette 'supporting_info_files_controller' do
        paper.supporting_information_files.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
      end
    end

    it "allows updates for title and caption" do
      with_aws_cassette 'supporting_info_files_controller' do
        do_request

        file = paper.reload.supporting_information_files.last
        expect(file.caption).to eq("new caption")
        expect(file.title).to eq("new title")
      end
    end
  end
end
