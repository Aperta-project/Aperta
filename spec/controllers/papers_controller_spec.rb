require 'rails_helper'

describe PapersController do
  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.build_stubbed(:journal) }
  let(:paper) { FactoryGirl.build(:paper) }

  describe 'GET index' do
    subject(:do_request) { get :index, format: :json }
    let(:papers) { [active_paper, inactive_paper] }
    let(:active_paper) { FactoryGirl.build_stubbed(:paper, active: true) }
    let(:inactive_paper) { FactoryGirl.build_stubbed(:paper, active: false) }

    it_behaves_like "an unauthenticated json request"

    context 'and the user is signed in' do
      before do
        stub_sign_in(user)
        allow(user).to receive(:filter_authorized).and_return instance_double(
          'Authorizations::Query::Result',
          objects: papers
        )
      end

      it { is_expected.to responds_with 200 }

      it 'returns papers the user has access to' do
        expect(user).to receive(:filter_authorized).with(
          :view,
          Paper.all.includes(:roles, jorunal: :creator_role)
        ).and_return instance_double(
          'Authorizations::Query::Result',
          objects: papers
        )
        do_request
        expect(res_body['papers'].count).to eq(2)
      end

      it 'includes active and inactive paper count in the response' do
        do_request
        expect(res_body['meta']['total_active_papers']).to eq(1)
        expect(res_body['meta']['total_inactive_papers']).to eq(1)
      end
    end
  end

  describe 'GET show' do
    subject(:do_request) { get :show, id: paper.to_param, format: :json }
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it "responds with the paper" do
        expect(res_body['paper']['id']).to eq(paper.id)
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

  describe 'POST create - any authenticated user can create a paper' do
    subject(:do_request) do
      post(
        :create,
        paper: paper_params,
        format: :json
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:paper_params) do
      {
        title: 'My new paper',
        journal_id: journal.id,
        paper_type: 'Research'
      }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      before do
        stub_sign_in(user)
        allow(PaperFactory).to receive(:create).and_return paper
      end

      it 'creates a paper' do
        expect(PaperFactory).to receive(:create).with(
          paper_params,
          user
        ).and_return paper
        do_request
      end

      it { is_expected.to responds_with(201) }

      it 'responds with the created paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_created!)
          .with(paper, user: user)
        do_request
      end

      it 'does not call the DownloadManuscriptWorker' do
        expect(DownloadManuscriptWorker).to_not receive(:download_manuscript)
        do_request
      end

      context 'when a url is present in the paper params' do
        before do
          paper_params['url'] = 'someURL'
        end

        it 'calls DownloadManuscriptWorker' do
          expect(DownloadManuscriptWorker).to receive(:download_manuscript)
            .with(
              paper,
              "someURL",
              user,
              "http://test.host/api/ihat/jobs"
            )
          do_request
        end
      end

      context 'when the paper is invalid' do
        before do
          paper.title = nil
          expect(paper).to be_invalid
        end

        it "doesn't call DownloadManuscriptWorker" do
          expect(DownloadManuscriptWorker).to_not receive(:download_manuscript)
          do_request
        end

        it "returns a 422" do
          do_request
          expect(response.status).to eq(422)
        end
      end
    end
  end

  describe 'PUT update' do
    subject(:do_request) do
      put(
        :update,
        id: paper.to_param,
        format: :json,
        paper: { title: 'My new title' }
      )
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access and the paper is editable" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
        allow(Activity).to receive(:paper_edited!)
        paper.update_column(:editable, true)
      end

      it 'updates the paper' do
        do_request
        expect(paper.reload.title).to eq('My new title')
      end

      it { is_expected.to responds_with(204) }

      it 'creates an Activity' do
        expect(Activity).to receive(:paper_edited!).with(paper, user: user)
        do_request
      end

    end

    context "when the user has access and the paper is NOT editable" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return true
        paper.update_column(:editable, false)
      end

      it { is_expected.to responds_with(422) }

      it 'responds with an error' do
        do_request
        expect(res_body['errors']['editable']).to \
          include('This paper is currently locked for review.')
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET comment_looks' do
    subject(:do_request) do
      get :comment_looks, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:task) { FactoryGirl.create(:task, paper: paper)}

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:comment) { FactoryGirl.create(:comment, task: task) }
      let!(:other_user) { FactoryGirl.create(:user) }
      let!(:comment_looks) do
        [current_user_comment_look, other_user_comment_look]
      end
      let!(:current_user_comment_look) do
        FactoryGirl.create(:comment_look, comment: comment, user: user)
      end
      let!(:other_user_comment_look) do
        FactoryGirl.create(:comment_look, comment: comment, user: other_user)
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the current user's comment_looks for the paper" do
        expect(res_body['comment_looks'].length).to be(1)
        expect(res_body['comment_looks'][0]['id']).to eq(current_user_comment_look.id)
      end

      it "does not return other user's comment looks on the paper" do
        look_ids = res_body['comment_looks'].map { |hsh| hsh['id'] }
        expect(look_ids).to_not include(other_user_comment_look.id)
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

  describe 'GET versioned_texts' do
    subject(:do_request) do
      get :versioned_texts, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:versioned_text) do
        paper.versioned_texts.create!(
          major_version: 1,
          minor_version: 2
        )
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's versioned_texts" do
        versioned_text_ids = res_body['versioned_texts'].map { |hsh| hsh['id'] }
        expect(versioned_text_ids.length).to eq paper.versioned_texts.count
        expect(versioned_text_ids).to \
          contain_exactly(*paper.versioned_texts.map(&:id))
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

  describe 'GET workflow_activities' do
    subject(:do_request) do
      get :workflow_activities, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:activities) { [ manuscript_activity, workflow_activity ] }
      let!(:manuscript_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'manuscript')
      end
      let!(:workflow_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'workflow')
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's workflow & manuscript activities" do
        feed_messages = res_body['feeds'].map { |hsh| hsh['message'] }
        expect(feed_messages.length).to eq paper.activities.length

        expect(feed_messages).to \
          contain_exactly(
            manuscript_activity.message,
            workflow_activity.message
          )
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'GET manuscript_activities' do
    subject(:do_request) do
      get :manuscript_activities, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      let!(:activities) { [ manuscript_activity, workflow_activity ] }
      let!(:manuscript_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'manuscript')
      end
      let!(:workflow_activity) do
        FactoryGirl.create(:activity, subject: paper, feed_name: 'workflow')
      end

      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's manuscript activities only" do
        feed_messages = res_body['feeds'].map { |hsh| hsh['messages'] }
        expect(feed_messages.length).to eq \
          paper.activities.where(feed_name: 'manuscript').length
        expect(feed_messages).to \
          contain_exactly(manuscript_activity.message)
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

  describe 'GET snapshots' do
    subject(:do_request) do
      get :snapshots, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }
    let(:snapshot_1) { FactoryGirl.build(:snapshot) }
    let(:snapshot_2) { FactoryGirl.build(:snapshot) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        paper.snapshots << snapshot_1 << snapshot_2
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's snapshots" do
        snapshot_ids = res_body['snapshots'].map { |hsh| hsh['id'] }
        expect(snapshot_ids.length).to eq(paper.snapshots.length)
        expect(snapshot_ids).to contain_exactly(snapshot_1.id, snapshot_2.id)
      end
    end
  end

  describe 'GET related_articles' do
    subject(:do_request) do
      get :related_articles, id: paper.id, format: :json
    end
    let!(:paper) { FactoryGirl.create(:paper) }
    let!(:related_article) { FactoryGirl.create(:related_article, paper: paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit_related_articles, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(200) }

      it "responds with the paper's related_articles" do
        expect(res_body['related_articles'].length).to eq(1)
        expect(res_body['related_articles'][0]['id']).to eq(related_article.id)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:edit_related_articles, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end


  describe "GET download" do
    subject(:do_request) do
      get :download, id: paper.id, format: format
    end
    let(:format) { :docx }

    let(:url) { "http://theurl.com" }
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
      end

      context 'requested format is ePub' do
        let(:format) { :epub }
        let(:epub_converter) do
          instance_double(EpubConverter, fs_filename: 'za-file.eps')
        end

        it 'sends an ePub file back' do
          expect(EpubConverter).to receive(:new).with(paper, user)
            .and_return epub_converter
          expect(epub_converter).to receive_message_chain('epub_stream.string')
            .and_return 'my epub file contents'

          do_request

          expect(response.body).to eq('my epub file contents')
          expect(response.headers['Content-Disposition']).to \
            include('filename="za-file.eps"')
        end
      end

      context 'requested format is PDF' do
        let(:format) { :pdf }
        let(:pdf_converter) do
          instance_double(PDFConverter, fs_filename: 'za-file.pdf')
        end

        it "sends a pdf file back if there's a pdf extension" do
          expect(PDFConverter).to receive(:new).with(paper, user)
            .and_return pdf_converter
          expect(pdf_converter).to receive(:convert)
            .and_return 'my pdf file contents'

          do_request

          expect(response.body).to eq('my pdf file contents')
          expect(response.headers['Content-Disposition']).to \
            include('filename="za-file.pdf"')
        end
      end

      context 'requested format is docx' do
        let(:format) { :docx }

        context 'and no docx was uploaded' do
          it 'returns 404' do
            do_request
            expect(response.status).to eq(404)
          end
        end

        context 'and a docx file was uploaded' do
          let(:docx_url) { 'http://example.com/source.docx' }

          it 'redirects to the docx file' do
            # Force the controller to use our mocked paper
            allow(controller).to receive(:paper).and_return(paper)
            latest_version = double(paper.latest_version)
            allow(paper).to receive(:latest_version)
              .and_return(latest_version)
            expect(latest_version).to receive(:source_url)
              .and_return(docx_url).twice

            do_request
            expect(response).to redirect_to(docx_url)
          end
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

  describe 'PUT toggle_editable' do
    subject(:do_request) do
      put :toggle_editable, id: paper.id, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return true
      end

      it "toggles the paper's editable state" do
        paper.update_attribute(:editable, false)
        do_request
        expect(response.status).to eq(200)
        expect(paper.reload.editable).to eq true
      end

      it 'creates an Activity' do
        expect(Activity).to receive(:editable_toggled!)
          .with(paper, user: user)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK when the paper is valid' do
        do_request
        expect(response).to responds_with(200)
      end

      it 'responds with 422 Unprocessible Entity when the paper is invalid' do
        paper.update_attribute(:title, '')
        expect(paper.valid?).to be(false)
        do_request
        expect(response).to responds_with(422)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:manage_workflow, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT submit' do
    subject(:do_request) do
       put :submit, id: paper.id, format: :json
    end
    let(:paper) { FactoryGirl.create(:paper) }

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:submit, paper)
          .and_return true
      end

      context 'Gradual Engagement' do
        before do
          paper.update(gradual_engagement: true)
        end

        it 'makes an initial submission' do
          do_request
          expect(paper.reload).to be_initially_submitted
        end

        it 'creates an activity' do
          expect(Activity).to receive(:paper_initially_submitted!)
            .with(paper, user: user)
          do_request
        end
      end

      context 'Full submission (not gradual engagement)' do
        it 'submits the paper' do
          do_request
          expect(response.status).to eq(200)
          expect(paper.reload.submitted?).to eq true
          expect(paper.editable).to eq false
        end

        it 'creates an Activity' do
          expect(Activity).to receive(:paper_submitted!)
            .with(paper, user: user)
          do_request
        end
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:submit, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT reactivate' do
    subject(:do_request) do
       put :reactivate, id: paper.to_param, format: :json
    end
    let(:paper) { FactoryGirl.build_stubbed(:paper) }

    before do
      allow(Paper).to receive(:find)
        .with(paper.to_param)
        .and_return paper
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:reactivate, paper)
          .and_return true
        allow(paper).to receive(:reactivate!)
      end

      it 'reactivates the paper' do
        expect(paper).to receive(:reactivate!)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:reactivate, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end

  describe 'PUT withdraw' do
    subject(:do_request) do
       put :withdraw, id: paper.to_param, format: :json, reason: withdrawal_reason
    end
    let(:paper) { FactoryGirl.build_stubbed(:paper) }
    let(:withdrawal_reason) { 'It was a whoopsie' }

    before do
      allow(Paper).to receive(:find)
        .with(paper.to_param)
        .and_return paper
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user has access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:withdraw, paper)
          .and_return true
        allow(paper).to receive(:withdraw!)
      end

      it 'withdraws the paper' do
        expect(paper).to receive(:withdraw!).with(withdrawal_reason)
        do_request
      end

      it 'responds with the paper' do
        do_request
        expect(res_body['paper']['id']).to eq(paper.id)
      end

      it 'responds with 200 OK' do
        do_request
        expect(response).to responds_with(200)
      end
    end

    context "when the user does not have access" do
      before do
        stub_sign_in(user)
        allow(user).to receive(:can?)
          .with(:withdraw, paper)
          .and_return false
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end
end
