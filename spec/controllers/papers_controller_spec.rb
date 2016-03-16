require 'rails_helper'

describe PapersController do
  let(:permitted_params) do
    [
      :short_title,
      :title,
      :abstract,
      :body,
      :paper_type,
      :decision,
      :decision_letter,
      :journal_id, {
        authors: [
          :first_name,
          :last_name,
          :affiliation,
          :email
        ],
        reviewer_ids: [],
        phase_ids: [],
        figure_ids: [],
        assignee_ids: [],
        editor_ids: []
      }
    ]
  end

  let(:user) { FactoryGirl.create(:user) }
  let(:journal) { FactoryGirl.build_stubbed(:journal) }
  let(:paper) { FactoryGirl.build(:paper) }

  before do
    sign_in user
  end

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

      it { responds_with 200 }

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
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
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

      context 'when the paper is invalid' do
        before do
          paper.title = nil
          expect(paper.valid?).to be(false)
          allow(PaperFactory).to receive(:create).and_return paper
        end

        it "renders the errors for the paper when it can't be saved" do
          post :create, paper: { journal_id: journal.id }, format: :json
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
        allow(user).to receive(:can?)
          .with(:view, paper)
          .and_return true
        do_request
      end

      it { is_expected.to responds_with(403) }
    end
  end


  # describe "GET download" do
  #   expect_policy_enforcement
  #
  #   it "sends file back" do
  #     allow(controller).to receive(:render).and_return(nothing: true)
  #     expect(controller).to receive(:send_data)
  #     get :download, id: paper.id, format: :epub
  #   end
  #
  #   it "sends a pdf file back if there's a pdf extension" do
  #     allow_any_instance_of(PDFConverter).to receive(:convert).and_return "<html><body>PDF CONTENT</body></html>"
  #     allow(controller).to receive(:render).and_return(nothing: true)
  #     expect(controller).to receive(:send_data)
  #     get :download, format: :pdf, id: paper.id
  #   end
  #
  #   context 'when downloading docx' do
  #     context 'and no docx was uploaded' do
  #       it 'returns 404' do
  #         get :download, id: paper.id, format: :docx
  #         expect(response.status).to eq(404)
  #       end
  #     end
  #
  #     context 'and a docx file was uploaded' do
  #       let(:docx_url) { 'http://example.com/source.docx' }
  #
  #       it 'redirects to the docx file' do
  #         # Force the controller to use our mocked paper
  #         allow(controller).to receive(:paper).and_return(paper)
  #         latest_version = double(paper.latest_version)
  #         allow(paper).to receive(:latest_version)
  #           .and_return(latest_version)
  #         expect(latest_version).to receive(:source_url)
  #           .and_return(docx_url).twice
  #         get :download, id: paper.id, format: :docx
  #         expect(response).to redirect_to(docx_url)
  #       end
  #     end
  #   end
  # end
  #
  #
  # describe "PUT 'upload'" do
  #   let(:url) { "http://theurl.com" }
  #   it "initiates manuscript download" do
  #     expect(DownloadManuscriptWorker).to receive(:perform_async)
  #       .with(paper.id, url, "http://test.host/api/ihat/jobs",
  #             paper_id: paper.id, user_id: user.id)
  #     put :upload, id: paper.id, url: url, format: :json
  #   end
  # end
  #
  # describe "PUT 'submit'" do
  #   expect_policy_enforcement
  #
  #   let(:submit) { put :submit, id: paper.id, format: :json}
  #
  #   authorize_policy(PapersPolicy, true)
  #
  #   context 'Gradual Engagement' do
  #     it 'makes an initial submission' do
  #       paper.update(gradual_engagement: true)
  #       submit
  #       expect(paper.reload).to be_initially_submitted
  #     end
  #   end
  #
  #   it "submits the paper" do
  #     submit
  #     expect(response.status).to eq(200)
  #     expect(paper.reload.submitted?).to eq true
  #     expect(paper.editable).to eq false
  #   end
  # end
  #
  # describe "PUT 'withdraw'" do
  #   let!(:paper) do
  #     FactoryGirl.create(:paper, journal: journal, creator: user, body: "This is the body")
  #   end
  #
  #   let(:user) { create :user }
  #
  #   context 'and the user has withdraw permission' do
  #     before do
  #       allow_any_instance_of(User).to receive(:can?)
  #         .with(:withdraw, paper)
  #         .and_return true
  #     end
  #
  #     it 'withdraws the paper' do
  #       put :withdraw,
  #           id: paper.id,
  #           reason: 'Conflict of interest',
  #           format: :json
  #       expect(response.status).to eq(200)
  #       reason = paper.reload.latest_withdrawal_reason
  #       expect(reason).to eq('Conflict of interest')
  #
  #       expect(paper.withdrawn?).to eq true
  #       expect(paper.editable).to eq false
  #     end
  #   end
  #
  #   context 'does not have withdraw permission' do
  #     before do
  #       allow_any_instance_of(User).to receive(:can?)
  #         .with(:withdraw, paper)
  #         .and_return false
  #     end
  #
  #     it 'does not withdraw the paper' do
  #       put :withdraw,
  #           id: paper.id,
  #           reason: 'Conflict of interest',
  #           format: :json
  #       expect(response.status).to eq(403)
  #     end
  #   end
  # end
  #
  # describe "PUT 'toggle_editable'" do
  #   expect_policy_enforcement
  #
  #   authorize_policy(PapersPolicy, true)
  #   it "switches the paper's editable state" do
  #     paper.update_attribute(:editable, false)
  #     put :toggle_editable, id: paper.id, format: :json
  #     expect(response.status).to eq(200)
  #     expect(paper.reload.editable).to eq true
  #   end
  # end
  #
  # describe "GET 'activity'" do
  #   let(:weak_user) { FactoryGirl.create :user }
  #
  #   before do
  #     PaperRole.create(
  #       user: weak_user,
  #       paper: paper,
  #       old_role: PaperRole::COLLABORATOR)
  #   end
  #
  #   context "for manuscript feed" do
  #     context 'and the user can view manuscript_activities' do
  #       action_policy(PapersPolicy, :manuscript_activities, true)
  #
  #       it 'returns the feed' do
  #         get :manuscript_activities, id: paper.to_param, format: :json
  #         expect(response.status).to eq(200)
  #       end
  #     end
  #
  #     context 'and the user cannot view manuscript_activities' do
  #       action_policy(PapersPolicy, :manuscript_activities, false)
  #
  #       it 'returns a 403' do
  #         sign_in weak_user
  #         get :manuscript_activities, id: paper.to_param, format: :json
  #         expect(response.status).to eq(403)
  #       end
  #     end
  #   end
  #
  #   context 'for workflow feed' do
  #     context 'and the user can view workflow_activities' do
  #       action_policy(PapersPolicy, :workflow_activities, true)
  #
  #       it 'returns the feed' do
  #         get :workflow_activities, id: paper.to_param, format: :json
  #         expect(response.status).to eq(200)
  #       end
  #     end
  #
  #     context 'and the user cannot view workflow_activities' do
  #       action_policy(PapersPolicy, :workflow_activities, false)
  #
  #       it 'returns a 403' do
  #         sign_in weak_user
  #         get :workflow_activities, id: paper.to_param, format: :json
  #         expect(response.status).to eq(403)
  #       end
  #     end
  #   end
  # end
  #
  # describe "GET 'snapshots'" do
  #   let(:phase) { FactoryGirl.create(:phase, paper: paper) }
  #   let(:task1) do
  #     FactoryGirl.create :ethics_task,
  #                        paper: paper,
  #                        phase: phase
  #   end
  #   let(:task2) do
  #     FactoryGirl.create :publishing_related_questions_task,
  #                        paper: paper,
  #                        phase: phase
  #   end
  #
  #   before do
  #     SnapshotService.new(paper).snapshot!(task1)
  #     SnapshotService.new(paper).snapshot!(task2)
  #   end
  #
  #   it 'returns all the snapshots' do
  #     get :snapshots, id: paper.to_param, format: :json
  #     expect(response.status).to eq(200)
  #     expect(res_body['snapshots'].count).to eq(2)
  #     expect(res_body['snapshots'][0].keys).to include(
  #       'source_id',
  #       'major_version',
  #       'minor_version',
  #       'contents')
  #   end
  # end
end
