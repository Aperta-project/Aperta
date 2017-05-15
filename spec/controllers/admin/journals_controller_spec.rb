require 'rails_helper'

describe Admin::JournalsController, redis: true do
  let(:journal) do
    FactoryGirl.create(
      :journal,
      :with_creator_role,
      :with_staff_admin_role
    )
  end
  let(:user) { FactoryGirl.build_stubbed :user }

  describe '#create' do
    subject(:do_request) do
      post :create,
           format: 'json',
           admin_journal: { name: 'new journal name',
                            description: 'new journal desc',
                            doi_journal_prefix: 'journal.SHORTJPREFIX1',
                            doi_publisher_prefix: 'SHORTJPREFIX1',
                            last_doi_issued: '100001',
                            logo_url: logo_url
                          }
    end

    let(:logo_url) { nil } # by default, do not upload logo

    it_behaves_like "an unauthenticated json request"

    context 'when the user has access' do
      before do
        stub_sign_in user
        allow(user).to receive(:can?) do |action, object|
          expect(action).to eq(:administer)
          expect(object).to be_kind_of(Journal)
          true
        end
      end

      it 'creates a journal' do
        expect do
          do_request
        end.to change { Journal.count }.by 1
        journal = Journal.last
        expect(journal.name).to eq 'new journal name'
        expect(journal.description).to eq 'new journal desc'
        expect(response.status).to eq 201
      end

      describe 'uploading journal logo' do
        context 'when url is provided' do
          let(:logo_url) { 'http://s3.com/pending/logo.png' }

          it 'calls the journal logo service class' do
            expect(DownloadJournalLogoWorker).to receive(:perform_async).with(kind_of(Integer), logo_url)
            do_request
          end
        end

        context 'when url is not provided' do
          it 'does not call the journal logo service class' do
            expect(DownloadJournalLogoWorker).to_not receive(:perform_async)
            do_request
          end
        end

        context 'when url is not a new logo stored in a temporary s3 bucket' do
          let(:logo_url) { 'http://s3.com/logo.png' }

          it 'does not call the journal logo service class' do
            expect(DownloadJournalLogoWorker).to_not receive(:perform_async)
            do_request
          end
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?) do |action, object|
          expect(action).to eq(:administer)
          expect(object).to be_kind_of(Journal)
          false
        end
      end

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
            admin_journal: {name: 'new journal name'}
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, journal)
          .and_return true
      end

      it "renders status 2xx and the journal is updated successfully" do
        expect do
          do_request
        end.to change { Journal.pluck(:name) }.to contain_exactly 'new journal name'
        expect(response.status).to eq 204
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in user
        allow(user).to receive(:can?)
          .with(:administer, journal)
          .and_return false
      end

      it "renders status 403" do
        do_request
        expect(response.status).to eq 403
      end
    end
  end
end
