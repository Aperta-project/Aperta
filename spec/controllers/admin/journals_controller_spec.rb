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

      it "renders status 2xx" do
        with_aws_cassette('admin_journal_controller') do
          patch :update, id: journal.id, admin_journal: { epub_cover: image_file }
        end
        expect(response.status).to eq 200
      end
    end

    context "uploading epub cover" do
      before do
        assign_journal_role journal, admin, :admin
        sign_in admin
      end

      let(:url) { "http://someawesomeurl.com" }
      let(:journal) { create :journal }
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
