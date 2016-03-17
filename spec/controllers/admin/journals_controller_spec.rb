require 'rails_helper'

describe Admin::JournalsController, redis: true do
  let(:journal) { create(:journal_with_roles_and_permissions) }
  let(:site_admin) { create :user, :site_admin }
  let(:journal_admin) do
    ja = create :user
    assign_journal_role(journal, ja, :admin)
    ja
  end
  let(:image_file) { fixture_file_upload 'yeti.jpg' }

  describe '#create' do
    subject(:do_request) do
      post :create,
           format: 'json',
           admin_journal: { name: 'new journal name', description: 'new journal desc' }
    end

    context 'when the user has access' do
      before do
        sign_in site_admin
      end

      it 'creates a journal' do
        do_request
        journal = Journal.last
        expect(journal.name).to eq 'new journal name'
        expect(journal.description).to eq 'new journal desc'
        expect(response.status).to eq 201
      end
    end

    context "when the user does not have access" do
      let(:journal_admin) { create :user }
      before { assign_journal_role(journal, journal_admin, :admin) }

      before do
        sign_in journal_admin
      end
      it_behaves_like "an unauthenticated json request"

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end

    context "when the user is unauthorized" do
      it "renders status 401" do
        do_request
        expect(response.status).to eq 401
      end
    end
  end

  describe '#update' do
    subject(:do_request) do
      patch :update,
            format: 'json',
            id: journal.id,
            admin_journal: { epub_cover: image_file }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        sign_in journal_admin
      end

      it "renders status 2xx and the journal is updated successfully" do
        with_aws_cassette('admin_journal_controller') do
          do_request
        end
        expect(response.status).to eq 204
      end
    end

    context "uploading epub cover" do
      let(:url) { "http://someawesomeurl.com" }
      it "is successful for site_admin" do
        sign_in site_admin
        expect(DownloadEpubCover).to receive(:call).with(journal, url).and_return(journal)
        put :upload_epub_cover, format: "json", id: journal.id, url: url
        expect(response).to be_success
      end

      it "is successful for journal_admin" do
        sign_in journal_admin
        expect(DownloadEpubCover).to receive(:call).with(journal, url).and_return(journal)
        put :upload_epub_cover, format: "json", id: journal.id, url: url
        expect(response).to be_success
      end
    end

    context "when the user does not have access" do
      it "renders status 401" do
        with_aws_cassette('admin_journal_controller') do
          do_request
        end
        expect(response.status).to eq 401
      end
    end
  end
end
