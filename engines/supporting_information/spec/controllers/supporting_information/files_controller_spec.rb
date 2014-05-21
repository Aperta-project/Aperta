require 'spec_helper'

module SupportingInformation
  describe FilesController do
    let(:user) { create :user }
    let(:paper) do
      FactoryGirl.create(:paper, user: user)
    end

    before { sign_in user }

    describe "DELETE 'destroy'" do
      context "when authorized" do
        subject(:do_request) { delete :destroy, id: paper.supporting_information_files.last.id, paper_id: paper.id }
        before(:each) do
          paper.supporting_information_files.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
        end

        it "destroys the file record" do
          expect {
            do_request
          }.to change{SupportingInformation::File.count}.by -1
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
          do_request
          expect(response.status).to eq(404)
        end
      end
    end

    describe "POST 'create'" do
      subject(:do_request) do
        post :create, paper_id: paper.to_param, supporting_information_file: { attachment: fixture_file_upload('yeti.tiff', "image/tiff") }
      end

      it_behaves_like "when the user is not signed in"

      it "saves the attachment to this paper" do
        expect { do_request }.to change(SupportingInformation::File, :count).by(1)
        expect(SupportingInformation::File.last.paper).to eq paper
      end

      it "redirects to paper's edit page" do
        do_request
        expect(response).to redirect_to edit_paper_path(paper)
      end

      context "when the attachments are in an array" do
        subject(:do_request) do
          post :create, paper_id: paper.to_param, supporting_information_file: { attachment: [fixture_file_upload('yeti.tiff', 'image/tiff'), fixture_file_upload('yeti.jpg', 'image/jpg')] }
        end

        it "saves each attachment to this paper" do
          expect { do_request }.to change(SupportingInformation::File, :count).by(2)
          expect(SupportingInformation::File.last.paper).to eq paper
        end
      end

      context "when it's an AJAX request" do
        subject(:do_request) do
          post :create, paper_id: paper.to_param, supporting_information_file: { attachment: fixture_file_upload('yeti.tiff', 'image/tiff') }, format: :json
        end

        it "responds with a JSON array of figure data" do
          do_request
          figure = SupportingInformation::File.last
          expect(JSON.parse(response.body)).to eq(
            {
              files: [
                { id: figure.id,
                  filename: "yeti.tiff",
                  alt: "Yeti",
                  src: "/uploads/paper/1/supporting_information/file/attachment/1/yeti.tiff",
                  title: "Title: yeti.tiff",
                  caption: nil,
                  paper_id: paper.id }
              ]
            }.with_indifferent_access
          )
        end
      end
    end

    describe "PUT 'update'" do
      subject(:do_request) { patch :update, id: paper.supporting_information_files.last.id, paper_id: paper.id, supporting_information_file: {title: "new title", caption: "new caption"} }
      before(:each) do
        paper.supporting_information_files.create! attachment: fixture_file_upload('yeti.tiff', 'image/tiff')
      end

      it "allows updates for title and caption" do
        do_request

        file = paper.supporting_information_files.last
        expect(file.caption).to eq("new caption")
        expect(file.title).to eq("new title")
      end
    end
  end
end
