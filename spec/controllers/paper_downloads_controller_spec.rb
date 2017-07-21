require 'rails_helper'

describe PaperDownloadsController, type: :controller do
  include Rails.application.routes.url_helpers

  let!(:paper) { create(:paper, :version_with_file_type, :with_creator) }
  let!(:paper_version) do
    paper.reload # weirdly, this is needed for paper.file to not be nil
    create(
      :paper_version,
      paper: paper,
      file_type: 'docx',
      manuscript_s3_path: 'sample/path',
      manuscript_filename: 'name.docx'
    )
  end
  let!(:manuscript_attachment) do
     create(:manuscript_attachment,
     owner: paper,
     file:'name.docx',
     s3_dir: 'sample/path',
     )
   end
  let!(:user) { create(:user) }

  describe 'GET show' do
    subject(:do_request) do
      get(
        :show,
        id: paper.to_param,
        paper_version_id: paper_version.to_param,
        export_format: 'docx',
        format: :json
      )
    end

    it_behaves_like 'an unauthenticated json request'

    context 'as a user with access to a paper' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      it 'redirects to the correct s3 file' do
        quoted = Regexp.quote(paper_version.s3_full_path)
        expect(do_request).to redirect_to(/#{quoted}.+Amz-SignedHeaders/)
      end

      context 'a synchronous conversion is requested' do
        let!(:paper_version) do
          paper.reload # weirdly, this is needed for paper.file to not be nil
          paper.file.update(file_type: 'pdf')
          create(
            :paper_version,
            paper: paper,
          )
        end

        subject(:do_request) do
          get(
            :show,
            id: paper.to_param,
            paper_version_id: paper_version.to_param,
            export_format: 'pdf_with_attachments',
            format: :json
          )
        end

        it 'sends data to the browser', vcr: { cassette_name: 'pdf_file', match_requests_on: [:method] } do
          do_request
          expect(response).to be_success
          expect(response.headers['Content-Disposition']).to match /attachment/
          expect(response.headers['Content-Type']).to eq 'application/pdf'
        end
      end

      context 'the PaperVersion is not specified' do
        subject(:do_request) do
          get(
            :show,
            id: paper.to_param,
            export_format: 'docx',
            format: :json
          )
        end
        let(:expected_paper_version) { paper.latest_version }

        it 'redirects to the file corresponding to latest paper version' do
          quoted = Regexp.quote(expected_paper_version.s3_full_path)
          expect(do_request).to redirect_to(/#{quoted}.+Amz-SignedHeaders/)
        end
      end

      context 'the specified PaperVersion does not belong to the paper' do
        let!(:paper_version) do
          create(
            :paper_version,
            file_type: 'docx',
            manuscript_s3_path: 'sample/path',
            manuscript_filename: 'name.docx'
          )
        end
        let!(:manuscript_attachment) do
          create(:manuscript_attachment, owner: paper_version.paper)
        end

        it 'returns a 404' do
          do_request
          expect(response.status).to eq(404)
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
end
