require 'rails_helper'

describe Admin::JournalsController, redis: true do
  let(:journal) { create(:journal_with_roles_and_permissions) }
  let(:admin) { create :user, :site_admin }
  let(:image_file) { fixture_file_upload 'yeti.jpg' }

  describe '#create' do
    context 'when the user is authorized' do
      before do
        sign_in admin
      end

      it 'creates a journal' do
        post :create, admin_journal: { name: 'new journal name', description: 'new journal desc' }, format: :json
        journal = Journal.last
        expect(journal.name).to eq 'new journal name'
        expect(journal.description).to eq 'new journal desc'
        expect(response.status).to eq 201
      end
    end

    context "when the user has insufficient permissions" do
      let(:journal_admin) { create :user }
      before { assign_journal_role(journal, journal_admin, :admin) }

      before do
        sign_in journal_admin
      end

      it "renders status 403" do
        xhr :post, :create, admin_journal: { name: 'journal name', description: 'journal desc' }
        expect(response.status).to eq 403
      end
    end

    context "when the user is unauthorized" do
      it "renders status 401" do
        xhr :post, :create, admin_journal: { name: 'journal name', description: 'journal desc' }
        expect(response.status).to eq 401
      end
    end
  end

  describe '#update' do
    context "when the journal is updated successfully" do
      before do
        sign_in admin
      end

      it "renders status 2xx" do
        with_aws_cassette('admin_journal_controller') do
          patch :update, id: journal.id, admin_journal: { epub_cover: image_file }, format: :json
        end
        expect(response.status).to eq 204
      end
    end

    context "uploading epub cover" do
      before do
        assign_journal_role journal, admin, :admin
        sign_in admin
      end

      let(:url) { "http://someawesomeurl.com" }
      it "is successful" do
        expect(DownloadEpubCover).to receive(:call).with(journal, url).and_return(journal)
        put :upload_epub_cover, format: "json", id: journal.id, url: url
        expect(response).to be_success
      end
    end

    context "when the user is unauthorized" do
      it "renders status 401" do
        with_aws_cassette('admin_journal_controller') do
          xhr :patch, :update, id: journal.id, admin_journal: { epub_cover: image_file }
        end
        expect(response.status).to eq 401
      end
    end
  end
end
