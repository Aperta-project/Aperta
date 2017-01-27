require 'rails_helper'

describe PaperConversionsController, type: :controller do
  include Rails.application.routes.url_helpers

  let(:paper) { instance_double(Paper, id: 99, file: nil, to_param: '99') }
  let(:job_id) { 'd5ee706f-a473-46ed-9777-3b7cd2905d08' }
  let(:user) { FactoryGirl.create :user }

  before do
    allow(Paper).to receive(:find)
      .with(paper.to_param)
      .and_return paper
  end

  describe 'GET export' do
    subject(:do_request) do
      get :export, id: paper.to_param, export_format: 'docx', format: :json
    end

    it_behaves_like 'an unauthenticated json request'

    context 'as a user with access to a paper' do
      let(:manuscript_attachment) do
        FactoryGirl.build_stubbed(:manuscript_attachment)
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      # There was previously a test set here for converting from an HTML docx
      # extraction into a real doxc file. That use case is no longer valid,
      # and TAHI no longer has this export functionality.

      context 'with a paper that is pdf' do
        let(:manuscript_attachment) do
          FactoryGirl.build_stubbed(:manuscript_attachment, :with_filename)
        end

        before do
          allow(paper).to receive(:file).and_return manuscript_attachment
          allow(paper).to receive(:file_type).and_return 'pdf'
        end

        it 'returns a url to check later' do
          get :export, id: paper.id, export_format: 'pdf', format: :json
          expect(response.status).to eq(202)
          expect(res_body['url']).to(
            eq(url_for(controller: :paper_conversions, action: :status,
                       id: paper.id, job_id: 'source', export_format: 'pdf')))
        end
      end

      context 'with a docx that the user uploaded' do
        let(:manuscript_attachment) do
          FactoryGirl.build_stubbed(:manuscript_attachment, :with_filename)
        end

        before do
          allow(paper).to receive(:file).and_return manuscript_attachment
          allow(paper).to receive(:file_type).and_return 'docx'
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
      let(:manuscript_attachment) do
        FactoryGirl.build_stubbed(:manuscript_attachment, :with_filename)
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        allow(paper).to receive(:file).and_return manuscript_attachment
        expect(paper.file.url).to_not be(nil)
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
        expect(res_body['url']).to eq(manuscript_attachment.url)
      end
    end

    context 'of a prior pdf version of a paper that is currently a docx' do
      let(:versioned_paper) { FactoryGirl.create :paper, :version_with_file_type }
      let(:versioned_text) do
        FactoryGirl.create :versioned_text, paper_id: versioned_paper.id,
          file_type: 'pdf', s3_dir: 'sample/path', file: 'name.pdf'
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, versioned_paper)
          .and_return true
        allow(Paper).to receive(:find)
          .with(versioned_paper.id.to_s)
          .and_return versioned_paper
      end

      it 'returns a signed S3 URL referencing a PDF file' do
        get :status, id: versioned_paper.id, job_id: 'source', format: :json,
          versioned_text_id: versioned_text.id
        expect(response.status).to eq(200)
        quoted = Regexp.quote(versioned_text.s3_full_path)
        expect(res_body['url']).to match(/#{quoted}.+Amz-SignedHeaders/)
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
