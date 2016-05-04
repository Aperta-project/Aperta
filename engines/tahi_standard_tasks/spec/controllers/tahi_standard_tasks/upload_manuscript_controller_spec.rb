require 'rails_helper'

module TahiStandardTasks
  describe UploadManuscriptController do
    routes { TahiStandardTasks::Engine.routes }
    let(:user) { FactoryGirl.create(:user) }
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:upload_manuscript_task, paper: paper) }

    describe 'PUT upload_manuscript' do
      subject(:do_request) do
        put :upload_manuscript, id: task.id, url: url, format: :json
      end
      let(:url) { "http://theurl.com" }

      it_behaves_like "an unauthenticated json request"

      context "when the user has access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return true
          allow(DownloadManuscriptWorker).to receive(:download_manuscript)
        end

        it "initiates manuscript download" do
          expect(DownloadManuscriptWorker).to receive(:download_manuscript)
            .with(paper, url, user)
          do_request
        end

        context "when the task exists but it's not an UploadManuscriptTask" do
          let(:task) { FactoryGirl.create(:task, paper: paper) }
          it "responds with a 404" do
            do_request
            expect(response).to responds_with(404)
          end
        end

        it "responds with 204" do
          do_request
          expect(response).to responds_with(204)
        end
      end

      context "when the user does not have access" do
        before do
          stub_sign_in(user)
          allow(user).to receive(:can?)
            .with(:edit, task)
            .and_return false
          do_request
        end

        it { is_expected.to responds_with(403) }
      end
    end
  end
end
