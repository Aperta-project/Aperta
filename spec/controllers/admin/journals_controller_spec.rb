require 'spec_helper'

describe Admin::JournalsController do
  let(:journal) { create(:journal) }
  let(:admin) { create :user, :admin }
  let(:image_file) { fixture_file_upload 'yeti.jpg' }

  describe '#create' do
    context 'when the user is authorized' do
      before do
        sign_in admin
      end

      it 'creates a journal' do
        post :create, admin_journal: { name: 'new journal name', description: 'new journal desc' }, format: :json
        expect(response.status).to eq 201
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

      it "stores the epub cover image successfully" do
        patch :update, id: journal.id, admin_journal: { epub_cover: image_file }
        uploader = journal.reload.epub_cover

        expect(uploader).to be_a EpubCoverUploader
        expect(uploader.file.filename).to eq 'yeti.jpg'
      end

      it "renders status 2xx" do
        patch :update, id: journal.id, admin_journal: { epub_cover: image_file }
        expect(response.status).to eq 200
      end
    end

    context "when the user is unauthorized" do
      it "renders status 401" do
        xhr :patch, :update, id: journal.id, admin_journal: { epub_cover: image_file }
        expect(response.status).to eq 401
      end
    end
  end
end
