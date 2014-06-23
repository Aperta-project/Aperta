require 'spec_helper'

describe PapersController do
  let(:permitted_params) { [:short_title, :title, :abstract, :body, :paper_type, :submitted, :decision, :decision_letter, :journal_id, {authors: [:first_name, :last_name, :affiliation, :email], reviewer_ids: [], declaration_ids: [], phase_ids: [], figure_ids: [], assignee_ids: [], editor_ids: []}] }

  let(:user) { create :user, admin: true }

  let(:submitted) { false }
  let(:paper) do
    FactoryGirl.create(:paper, :with_tasks, submitted: submitted, user: user)
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

    subject(:do_request) do
      post :create, { paper: { short_title: 'ABC101', journal_id: journal.id, paper_type: journal.paper_types.first }, format: :json }
    end

    it_behaves_like "an unauthenticated json request"

    context "when the user is signed in" do
      expect_policy_enforcement

      it "saves a new paper record" do
        do_request
        expect(Paper.where(short_title: 'ABC101').count).to eq(1)
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

      describe "adding authors to the paper" do
        it "assigns an author to the paper" do
          expect {
            do_request
          }.to change { Author.count }.by 1
        end

        it "assigns the right author to the paper" do
          do_request
          expect(Paper.last.authors.first.first_name).to eq(user.first_name)
        end
      end
    end
  end

  describe "PUT 'update'" do
    let(:params) { {} }

    subject(:do_request) do
      put :update, { id: paper.to_param, paper: { short_title: 'ABC101' }.merge(params) }
    end

    it_behaves_like "when the user is not signed in"

    context "when the user is signed in" do
      expect_policy_enforcement
      it "updates the paper" do
        do_request
        expect(paper.reload.short_title).to eq('ABC101')
      end
    end
  end

  describe "POST 'upload'" do
    pending "implementation will change when we get background workers... let's not write throwaway tests"
  end
end
