require 'rails_helper'

describe PaperConversionsController, type: :controller do
  include Rails.application.routes.url_helpers

  let(:paper) do
    FactoryGirl.create(:paper, :with_integration_journal, :with_creator)
  end
  let(:job_id) { 'd5ee706f-a473-46ed-9777-3b7cd2905d08' }
  let(:user) { create :user, :site_admin }

  before { sign_in user }
  describe '#export' do
    context 'as a user with access to a paper' do
      context 'with a paper that needs conversion' do
        it 'returns a url to check later' do
          VCR.use_cassette('convert_to_docx') do
            get :export, id: paper.id, export_format: 'docx', format: :json
          end
          expect(response.status).to eq(202)
          expect(res_body['url']).to(
            eq(url_for(controller: :paper_conversions, action: :status,
                       id: paper.id, job_id: job_id, export_format: 'docx')))
        end
      end

      context 'with a docx that the user uploaded' do
        let(:docx_url) { 'http://example.com/source.docx' }

        before do
          # Force the controller to use our mocked paper
          allow(controller).to receive(:paper).and_return(paper)
          latest_version = double(paper.latest_version)
          allow(paper).to receive(:latest_version)
            .and_return(latest_version)
          allow(latest_version).to receive(:source_url)
            .and_return(docx_url)
        end

        it 'returns a url to check later' do
          get :export, id: paper.id, export_format: 'docx', format: :json
          expect(response.status).to eq(202)
          expect(res_body['url']).to(
            eq(url_for(controller: :paper_conversions, action: :status,
                       id: paper.id, job_id: 'source', export_format: 'docx')))
        end

        it 'returns the download url when the status is checked' do
          get :status, id: paper.id, job_id: 'source', export_format: 'docx'
          expect(response.status).to eq(200)
          expect(res_body['url']).to eq(docx_url)
        end
      end
    end

    context 'as a user with no access' do
      let(:user) { create :user }
      it 'returns a 403' do
        get :export, id: paper.id, export_format: 'docx', format: :json
        expect(response.status).to eq(403)
      end
    end
  end

  describe 'GET #status' do
    it 'returns 202 when still processing' do
      VCR.use_cassette('check_docx_status') do
        get :status, id: paper.id, job_id: job_id, export_format: 'docx',
                     format: :json
        expect(response.status).to eq 202
      end
    end
  end
end
