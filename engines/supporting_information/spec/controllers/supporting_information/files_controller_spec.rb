require 'spec_helper'

module SupportingInformation
  describe FilesController, redis: true do
    routes { ::SupportingInformation::Engine.routes }
    let(:user) { create :user }
    let(:paper) do
      FactoryGirl.create(:paper, user: user)
    end

    before { sign_in user }

    describe "DELETE 'destroy'" do
      context "when authorized" do
        subject(:do_request) { delete :destroy, id: paper.supporting_information_files.last.id, paper_id: paper.id }
        before(:each) do
          with_aws_cassette 'supporting_info_files_controller' do
            paper.supporting_information_files.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
          end
        end

        it "destroys the file record" do
          expect {
            do_request
          }.to change{::SupportingInformation::File.count}.by -1
        end
      end

      context "when unauthorized" do
        let(:paper) do
          FactoryGirl.create(:paper)
        end

        subject(:do_request) do
          post :create, paper_id: paper.to_param, supporting_information_file: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }
        end

        it "will not allow access" do
          with_aws_cassette 'supporting_info_files_controller' do
            do_request
            expect(response.status).to eq(404)
          end
        end
      end
    end

    describe "POST 'create'" do
      let(:url) { "http://someawesomeurl.com" }
      it "creates the supporting file" do
        expect(DownloadSupportingInfoWorker).to receive(:perform_async)
        post :create, format: "json", paper_id: paper.to_param, url: url
        expect(response.status).to eq(200)
      end
    end

    describe "PUT 'update'" do
      subject(:do_request) { patch :update, id: paper.supporting_information_files.last.id, paper_id: paper.id, supporting_information_file: {title: "new title", caption: "new caption"} }
      before(:each) do
        with_aws_cassette 'supporting_info_files_controller' do
          paper.supporting_information_files.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
        end
      end

      it "allows updates for title and caption" do
        with_aws_cassette 'supporting_info_files_controller' do
          do_request

          file = paper.supporting_information_files.last
          expect(file.caption).to eq("new caption")
          expect(file.title).to eq("new title")
        end
      end
    end
  end
end
