require 'spec_helper'

describe PapersController do
  let(:permitted_params) { [:short_title, :title, :abstract, :body, :paper_type, :submitted, :decision, :decision_letter, :journal_id, {authors: [:first_name, :last_name, :affiliation, :email], reviewer_ids: [], phase_ids: [], figure_ids: [], assignee_ids: [], editor_ids: []}] }

  let(:user) { create :user, :site_admin }

  let(:submitted) { false }
  let(:paper) do
    FactoryGirl.create(:paper, submitted: submitted, user: user, body: "This is the body")
  end

  before { sign_in user }

  describe "GET download" do
    expect_policy_enforcement

    subject(:do_request) { get :download, id: paper.to_param }

    it "sends file back" do
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, id: paper.id
    end

    it "sends a pdf file back if there's a pdf extension" do
      allow(PDFConverter).to receive(:convert).and_return "<html><body>PDF CONTENT</body></html>"
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, format: :pdf, id: paper.id
    end
  end

  describe "GET 'show'" do
    let(:submitted) { true }
    subject(:do_request) { get :show, id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    it { should be_success }
  end

  describe "GET 'edit'" do
    subject(:do_request) { get :edit, id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    context "when the user is signed in" do
      expect_policy_enforcement

      it { should be_success }
      it { should render_template "ember/index" }
    end
  end

  describe "POST 'create'" do
    let(:journal) { FactoryGirl.create :journal }
    let(:new_title) { 'A full title' }

    subject(:do_request) do
      post :create, { paper: { title: new_title,
                               short_title: 'ABC101',
                               journal_id: journal.id,
                               paper_type: journal.paper_types.first },
                               format: :json }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      expect_policy_enforcement

      it "saves a new paper record" do
        do_request
        expect(Paper.where(short_title: 'ABC101').count).to eq(1)
      end

      context "with html tags in the title" do
        let(:new_title) { '<div>A full html title</div>' }
        it "gets rid of the tags" do
          do_request
          expect(Paper.last.title).to eq('A full html title')
        end
      end

      it "returns a 201 and the paper's id in json" do
        do_request
        expect(response.status).to eq(201)
        json = JSON.parse(response.body)
        expect(json['paper']['id']).to eq(Paper.first.id)
      end

      it "renders the errors for the paper if it can't be saved" do
        post :create, paper: { short_title: '' }, format: :json
        expect(response.status).to eq(422)
      end
    end
  end

  describe "PUT 'update'" do
    let(:params) { {} }
    let(:new_title) { 'A title' }
    subject(:do_request) do
      put :update, { id: paper.to_param, format: :json, paper: { title: new_title, short_title: 'ABC101' }.merge(params) }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      expect_policy_enforcement
      it "updates the paper" do
        do_request
        expect(paper.reload.short_title).to eq('ABC101')
      end

      it "will not update the body if it is nil" do
        # test to check that weird ember ghost requests can't reset the body
        new_body = nil
        put :update, { id: paper.to_param, format: :json, paper: { body: new_body }.merge(params) }
        expect(paper.reload.body).to_not eq(new_body)
      end

      context "when the paper is locked by another user" do
        before do
          other_user = create(:user)
          paper.locked_by = other_user
          paper.save
        end
        it "returns an error" do
          do_request
          expect(response.status).to eq(422)
          expect(JSON.parse(response.body)["errors"]).to have_key("locked_by_id")
        end
      end

      context "with html tags in the title" do
        let(:new_title) { '<div>A full html title</div>' }
        it "gets rid of the tags" do
          do_request
          expect(paper.reload.title).to eq('A full html title')
        end
      end
    end
  end

  describe "PUT 'upload'" do
    let(:url) { "http://theurl.com" }
    it "initiates manuscript download" do
      expect(DownloadManuscriptWorker).to receive(:perform_async)
      put :upload, id: paper.id, url: url
    end
  end

  describe "PUT 'submit'" do
    expect_policy_enforcement

    authorize_policy(PapersPolicy, true)
    it "submits the paper" do
      put :submit, id: paper.id, format: :json
      expect(response.status).to eq(200)
      expect(paper.reload.submitted).to eq true
      expect(paper.editable).to eq false
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

  describe "PUT 'heartbeat'" do
    expect_policy_enforcement

    subject(:do_request) do
      put :heartbeat, { id: paper.to_param, format: :json }
    end
    context "paper is locked" do
      before do
        paper.lock_by(user)
      end

      it "updates the paper timestamp" do
        old_heartbeat = 1.minute.ago
        paper.update_attribute :last_heartbeat_at, old_heartbeat
        do_request
        expect(paper.reload.last_heartbeat_at).to be > old_heartbeat
      end
    end

    context "paper is unlocked" do
      it "does not update the timestamp" do
        do_request
        expect(paper.reload.last_heartbeat_at).to be_nil
      end
    end
  end
end
