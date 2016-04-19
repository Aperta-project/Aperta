require 'rails_helper'

describe PaperConversionsController, type: :controller do
  include Rails.application.routes.url_helpers

  let(:paper) { FactoryGirl.create(:paper) }
  let(:job_id) { 'd5ee706f-a473-46ed-9777-3b7cd2905d08' }
  let(:user) { FactoryGirl.create :user }

  describe 'GET export' do
    subject(:do_request) do
      get :export, id: paper.to_param, export_format: 'docx', format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'as a user with access to a paper' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        allow(Paper).to receive(:find)
          .with(paper.to_param)
          .and_return paper
      end

      context 'with a paper that needs conversion' do
        subject(:do_request) do
          VCR.use_cassette('convert_to_docx') do
            get :export, id: paper.id, export_format: 'docx', format: :json
          end
        end

        before do
          # no source URL, needs conversion
          allow(paper).to receive_message_chain('latest_version.source_url')
            .and_return nil

          allow(PaperConverter).to receive(:export)
            .and_return double('job', job_id: job_id)
        end

        it 'initiates converting the paper' do
          expect(PaperConverter).to receive(:export)
            .with(paper, 'docx', user)
            .and_return double('job', job_id: job_id)
          do_request
        end

        it 'returns a url to check later' do
          do_request
          expect(response.status).to eq(202)
          expect(res_body['url']).to(
            eq(url_for(controller: :paper_conversions, action: :status,
                       id: paper.id, job_id: job_id, export_format: 'docx')))
        end
      end

      context 'with a docx that the user uploaded' do
        let(:docx_url) { 'http://example.com/source.docx' }

        before do
          allow(paper).to receive_message_chain('latest_version.source_url')
            .and_return docx_url
        end

        it 'returns a url to check later' do
          get :export, id: paper.id, export_format: 'docx', format: :json
          expect(response.status).to eq(202)

          expect(res_body['url']).to(
            eq(url_for(controller: :paper_conversions, action: :status,
                       id: paper.id, job_id: 'source', export_format: 'docx')))
        end
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET status' do
    subject(:do_request) do
      get(
        :status,
        id: paper.id, job_id: job_id, export_format: 'docx', format: :json
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context "when the user has access" do
      let(:docx_url) { 'http://example.com/source.docx' }

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        allow(Paper).to receive(:find)
          .with(paper.to_param)
          .and_return paper
        allow(paper).to receive_message_chain('latest_version.source_url')
          .and_return docx_url
      end

      it 'returns 202 when still processing' do
        VCR.use_cassette('check_docx_status') do
          do_request
          expect(response.status).to eq 202
        end
      end

      it 'returns the download url when the status is checked' do
        get :status, id: paper.id, job_id: 'source', export_format: 'docx', format: :json
        expect(response.status).to eq(200)
        expect(res_body['url']).to eq(docx_url)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
