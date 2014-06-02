require 'spec_helper'

describe Admin::JournalsController do
  describe '#update' do
    let(:journal) { create(:journal) }
    let(:admin) { create :user, :admin }
    let(:image_file) { fixture_file_upload 'yeti.jpg' }

    context "when the journal is updated successfully" do
      before do
        assign_journal_role journal, admin, :admin
        sign_in admin
      end
      it "stores the epub cover image successfully" do
        patch :update, id: journal.id, journal: { epub_cover: image_file }
        uploader = journal.reload.epub_cover

        expect(uploader).to be_a EpubCoverUploader
        expect(uploader.file.filename).to eq 'yeti.jpg'
      end

      it "renders status 2xx" do
        patch :update, id: journal.id, journal: { epub_cover: image_file }
        expect(response.status).to eq 200
      end
    end

    context "when the user is unauthorized" do
      it "renders status 401" do
        xhr :patch, :update, id: journal.id, journal: { epub_cover: image_file }
        expect(response.status).to eq 401
      end
    end
  end
end
