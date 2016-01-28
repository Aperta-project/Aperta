require 'rails_helper'

describe PapersController do
  include AuthorizationSpecHelper
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

  include AuthorizationSpecHelper

  permissions do
    permission action: 'view', applies_to: Paper.name
  end

  role 'Creator', participates_in: [Paper] do
    has_permission action: 'view', applies_to: Paper.name
  end

  let(:user) { create :user }

  let(:submitted) { false }
  let(:paper) do
    if submitted
      FactoryGirl.create(:paper, :submitted, creator: user, body: "This is the body")
    else
      FactoryGirl.create(:paper, creator: user, body: "This is the body")
    end
  end

  before do
    Authorizations::Configuration.reload
    sign_in user
  end

  authorize_policy(PapersPolicy, true)

  describe "GET index" do
    let(:active_paper_count) { 3 }
    let(:inactive_paper_count) { 2 }
    let(:response_papers) { res_body['papers'] }
    let(:response_meta) { res_body['meta'] }

    before do
      active_paper_count.times { FactoryGirl.create :paper, :active, creator: user }
      inactive_paper_count.times { FactoryGirl.create :paper, :inactive, creator: user }
    end

    context "when there are active and inactive papers owned by the user" do
      it "returns all papers" do
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(response_papers.count).to eq(active_paper_count + inactive_paper_count)
      end

      it "returns the correct meta response" do
        get :index, format: :json
        expect(response_meta['total_active_papers']).to eq(3)
        expect(response_meta['total_inactive_papers']).to eq(2)
      end
    end

    context "when there are other papers not owned by the user" do
      let(:paper_count) { 16 }

      it "returns just the user's papers" do
        other_user = FactoryGirl.create(:user)
        other_paper = FactoryGirl.create :paper, creator: other_user
        get :index, format: :json
        expect(response.status).to eq(200)
        expect(Paper.count).to eq(6)
        expect(response_papers.count).to eq(5)
      end
    end
  end

  describe "GET download" do
    expect_policy_enforcement

    it "sends file back" do
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, id: paper.id, format: :epub
    end

    it "sends a pdf file back if there's a pdf extension" do
      allow_any_instance_of(PDFConverter).to receive(:convert).and_return "<html><body>PDF CONTENT</body></html>"
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, format: :pdf, id: paper.id
    end

    context 'when downloading docx' do
      context 'and no docx was uploaded' do
        it 'returns 404' do
          get :download, id: paper.id, format: :docx
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
          get :download, id: paper.id, format: :docx
          expect(response).to redirect_to(docx_url)
        end
      end
    end
  end

  describe "GET 'show'" do
    let(:submitted) { true }
    subject(:do_request) { get :show, id: paper.to_param, format: :json }

    it { is_expected.to be_success }

  end

  describe "POST 'create'" do
    let(:journal) { FactoryGirl.create :journal }
    let(:new_title) { 'A full title' }

    subject(:do_request) do
      post :create, { paper: { title: new_title,
                               journal_id: journal.id,
                               paper_type: journal.paper_types.first },
                               format: :json }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      expect_policy_enforcement

      it "saves a new paper record" do
        do_request
        expect(Paper.where(title: new_title).count).to eq(1)
      end

      it "returns a 201 and the paper's id in json" do
        do_request
        expect(response.status).to eq(201)
        expect(res_body['paper']['id']).to eq(Paper.first.id)
      end

      it "renders the errors for the paper if it can't be saved" do
        post :create, paper: { journal_id: journal.id },
                      format: :json

        expect(response.status).to eq(422)
      end

      it "creates an Activity" do
        expect(Activity).to receive(:create).with(hash_including(
                                                    message: "Manuscript was created",
                                                    feed_name: 'manuscript'))
        do_request
      end

      it 'has a default title' do
        post :create, paper: { journal_id: journal.id,
                               paper_type: journal.paper_types.first },
                      format: :json

        expect(res_body['paper']['title']).to eq('Untitled')
      end
    end
  end

  describe "PUT 'update'" do
    let(:params) { {} }
    let(:new_title) { 'A title' }
    subject(:do_request) do
      put :update,
          id: paper.to_param,
          format: :json,
          paper: { title: new_title }.merge(params)
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      expect_policy_enforcement
      it "updates the paper" do
        do_request
        expect(paper.reload.title).to eq(new_title)
      end

      it "creates an Activity" do
        expect(Activity).to receive(:create).with(hash_including(
                                                    subject: paper,
                                                    message: "Manuscript was edited",
                                                    feed_name: 'manuscript'))
        put :update, { id: paper.to_param,
                       format: :json,
                       paper: {
                         title: new_title }.merge(params) }
      end

      it "will not update the body if it is nil" do
        # test to check that weird ember ghost requests can't reset the body
        put :update, { id: paper.to_param, format: :json, paper: { body: nil }.merge(params) }
        expect(paper.reload.body).not_to eq(nil)
      end
    end
  end

  describe "PUT 'upload'" do
    let(:url) { "http://theurl.com" }
    it "initiates manuscript download" do
      expect(DownloadManuscriptWorker).to receive(:perform_async)
      put :upload, id: paper.id, url: url, format: :json
    end
  end

  describe "PUT 'submit'" do
    expect_policy_enforcement

    let(:submit) { put :submit, id: paper.id, format: :json}

    authorize_policy(PapersPolicy, true)

    context 'Gradual Engagement' do
      it 'makes an initial submission' do
        paper.update(gradual_engagement: true)
        submit
        expect(paper.reload).to be_initially_submitted
      end
    end

    it "submits the paper" do
      submit
      expect(response.status).to eq(200)
      expect(paper.reload.submitted?).to eq true
      expect(paper.editable).to eq false
    end
  end

  describe "PUT 'withdraw'" do
    let(:user) { create :user }
    permission action: :withdraw_manuscript, applies_to: 'Paper', states: ['*']
    role 'Author' do
      has_permission action: 'withdraw_manuscript', applies_to: 'Paper'
    end

    role 'JournalStaff' do
      has_permission action: 'withdraw_manuscript', applies_to: 'Paper'
    end

    context 'has withdraw_manuscript permission' do
      context 'as the author' do
        before do
          assign_user user, to: paper, with_role: role_Author
        end

        it 'withdraws the paper' do
          put :withdraw,
              id: paper.id,
              reason: 'Conflict of interest',
              format: :json
          expect(response.status).to eq(200)
          reason = paper.reload.latest_withdrawal_reason
          expect(reason).to eq('Conflict of interest')

          expect(paper.withdrawn?).to eq true
          expect(paper.editable).to eq false
        end
      end

      context 'as journal staff' do
        before do
          assign_user user, to: paper.journal, with_role: role_JournalStaff
        end

        it 'withdraws the paper' do
          put :withdraw,
              id: paper.id,
              reason: 'Conflict of interest',
              format: :json
          expect(response.status).to eq(200)
          reason = paper.reload.latest_withdrawal_reason
          expect(reason).to eq('Conflict of interest')

          expect(paper.withdrawn?).to eq true
          expect(paper.editable).to eq false
        end
      end
    end

    context 'does not have withdraw_manuscript permission' do
      it 'does not withdraw the paper' do
        put :withdraw,
            id: paper.id,
            reason: 'Conflict of interest',
            format: :json
        expect(response.status).to eq(403)
      end
    end
  end

  describe "PUT 'toggle_editable'" do
    expect_policy_enforcement

    authorize_policy(PapersPolicy, true)
    it "switches the paper's editable state" do
      paper.update_attribute(:editable, false)
      put :toggle_editable, id: paper.id, format: :json
      expect(response.status).to eq(200)
      expect(paper.reload.editable).to eq true
    end
  end

  describe "GET 'activity'" do
    let(:weak_user) { FactoryGirl.create :user }

    before do
      PaperRole.create(
        user: weak_user,
        paper: paper,
        old_role: PaperRole::COLLABORATOR)
    end

    context "for manuscript feed" do
      context 'and the user can view manuscript_activities' do
        action_policy(PapersPolicy, :manuscript_activities, true)

        it 'returns the feed' do
          get :manuscript_activities, id: paper.to_param, format: :json
          expect(response.status).to eq(200)
        end
      end

      context 'and the user cannot view manuscript_activities' do
        action_policy(PapersPolicy, :manuscript_activities, false)

        it 'returns a 403' do
          sign_in weak_user
          get :manuscript_activities, id: paper.to_param, format: :json
          expect(response.status).to eq(403)
        end
      end
    end

    context 'for workflow feed' do
      context 'and the user can view workflow_activities' do
        action_policy(PapersPolicy, :workflow_activities, true)

        it 'returns the feed' do
          get :workflow_activities, id: paper.to_param, format: :json
          expect(response.status).to eq(200)
        end
      end

      context 'and the user cannot view workflow_activities' do
        action_policy(PapersPolicy, :workflow_activities, false)

        it 'returns a 403' do
          sign_in weak_user
          get :workflow_activities, id: paper.to_param, format: :json
          expect(response.status).to eq(403)
        end
      end
    end
  end

  describe "GET 'snapshots'" do
    let(:phase) { FactoryGirl.create(:phase, paper: paper) }
    let(:task1) do
      FactoryGirl.create :ethics_task,
                         paper: paper,
                         phase: phase
    end
    let(:task2) do
      FactoryGirl.create :publishing_related_questions_task,
                         paper: paper,
                         phase: phase
    end

    before do
      SnapshotService.new(paper).snapshot!(task1)
      SnapshotService.new(paper).snapshot!(task2)
    end

    it 'returns all the snapshots' do
      get :snapshots, id: paper.to_param, format: :json
      expect(response.status).to eq(200)
      expect(res_body['snapshots'].count).to eq(2)
      expect(res_body['snapshots'][0].keys).to include(
        'source_id',
        'major_version',
        'minor_version',
        'contents')
    end
  end
end
