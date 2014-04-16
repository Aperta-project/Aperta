require 'spec_helper'

describe PapersController do

  let(:permitted_params) { [:short_title, :title, :abstract, :body, :paper_type, :submitted, :decision, :decision_letter, :journal_id, {authors: [:first_name, :last_name, :affiliation, :email], reviewer_ids: [], declaration_ids: [], phase_ids: [], figure_ids: [], assignee_ids: [], editor_ids: []}] }

  let :user do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  before { sign_in user }

  describe "GET download" do
    let(:paper) do
      user.papers.create!(submitted: true, short_title: 'submitted-paper', journal: Journal.create!)
    end
    subject(:do_request) { get :download, id: paper.to_param }

    it "uses PaperPolicy to retrieve the paper" do
      policy = double('paper policy', paper: paper)
      expect(PaperPolicy).to receive(:new).and_return policy
      get :download, id: paper.id
      expect(assigns :paper).to eq(paper)
    end

    it "sends file back" do
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, id: paper.id
    end

    it "sends a pdf file back if there's a pdf extension" do
      allow(PDFKit).to receive_message_chain(:new, :to_pdf)
      allow(controller).to receive(:render).and_return(nothing: true)
      expect(controller).to receive(:send_data)
      get :download, format: :pdf, id: paper.id
    end
  end

  describe "GET 'show'" do
    let(:paper) do
      user.papers.create!(submitted: true, short_title: 'submitted-paper', journal: Journal.create!)
    end
    subject(:do_request) { get :show, id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    it { should be_success }
    it { should render_template :show }

    it "uses PaperPolicy to retrieve the paper" do
      policy = double('paper policy', paper: paper)
      expect(PaperPolicy).to receive(:new).and_return policy
      do_request
      expect(assigns :paper).to eq(paper)
    end

    it "assigns assigned tasks" do
      task = Task.create! assignee: user, title: 'Change the world', role: 'editor', phase: paper.task_manager.phases.first
      tasks = double 'tasks', tasks: [task]
      allow(TaskPolicy).to receive(:new).and_return(tasks)
      do_request
      expect(assigns :tasks).to include(task)
    end

    context "when the paper is not submitted" do
      before { paper.update_attribute(:submitted, false) }
      it { should redirect_to(edit_paper_path paper) }
    end
  end

  describe "GET 'edit'" do
    let(:paper) { user.papers.create! short_title: 'user\'s paper', journal: Journal.create!}
    subject(:do_request) { get :edit, id: paper.to_param }

    it_behaves_like "when the user is not signed in"

    it { should be_success }
    it { should render_template "ember/index" }

    it "uses PaperPolicy to retrieve the paper" do
      policy = double('paper policy', paper: paper)
      expect(PaperPolicy).to receive(:new).and_return policy
      do_request
      expect(assigns :paper).to eq(paper)
    end

    it "assigns assigned tasks" do
      task = Task.create! assignee: user, title: 'Change the world', role: 'editor', phase: paper.task_manager.phases.first
      tasks = double 'tasks', tasks: [task]
      allow(TaskPolicy).to receive(:new).and_return(tasks)
      do_request
      expect(assigns :tasks).to include(task)
    end

    context "when the paper is submitted" do
      before { paper.update_attribute(:submitted, true) }
      it { should redirect_to(paper_path(paper)) }
    end
  end

  describe "GET 'new'" do
    subject(:do_request) { get :new }

    it_behaves_like "when the user is not signed in"

    it { should be_success }
    it { should render_template :new }
  end

  describe "POST 'create'" do
    before { Journal.create! }

    subject(:do_request) do
      post :create, { paper: { short_title: 'ABC101', journal_id: Journal.last.id } }
    end

    it_behaves_like "when the user is not signed in"

    it "saves a new paper record" do
      do_request
      expect(Paper.first).to be_persisted
    end

    it "assigns the paper to the current user" do
      do_request
      expect(Paper.first.user).to eq(user)
    end

    it "returns a 201 and the paper's id in json" do
      do_request
      expect(response.status).to eq(201)
      json = JSON.parse(response.body)
      expect(json['paper']['id']).to eq(Paper.first.id)
    end

    it "renders new template if the paper can't be saved" do
      post :create, { paper: { short_title: '' } }
      expect(response.status).to eq(422)
    end
  end

  describe "PUT 'update'" do
    let(:paper) { Paper.create! short_title: 'paper-yet-to-be-updated', journal: Journal.create! }

    let(:params) { {} }

    subject(:do_request) do
      put :update, { id: paper.to_param, paper: { short_title: 'ABC101' }.merge(params) }
    end

    describe "authors" do
      context "when there is an authors key in params" do
        let(:authors) { [{ first_name: 'Bob', last_name: 'Marley', affiliation: "Jamaica Inc.", email: 'jamaican@example.com' }] }
        let(:params) { { authors: authors } }

        it "decodes JSON string into an array before saving" do
          do_request
          expect(paper.reload.authors).to eq authors.map(&:with_indifferent_access)
        end
      end

      context "when authors key is not present" do
        let(:params) { {} }

        it "decodes JSON string into an array before saving" do
          do_request
          expect(paper.reload.authors).to be_empty
        end
      end
    end

    it_behaves_like "when the user is not signed in"

    it "updates the paper" do
      do_request
      expect(paper.reload.short_title).to eq('ABC101')
    end
  end

  describe "POST 'upload'" do
    let(:paper) { Paper.create! short_title: 'paper-needs-uploads', journal: Journal.create! }

    let(:uploaded_file) do
      docx_file_type = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'
      fixture_file_upload('about_turtles.docx', docx_file_type, :binary)
    end

    subject :do_request do
      post :upload, id: paper.to_param, upload_file: uploaded_file
    end

    before do
      allow(OxgarageParser).to receive(:parse).and_return(
        title: 'This is a Title About Turtles',
        body: "Heroes in a half shell! Turtle power!"
      )
    end

    it_behaves_like "when the user is not signed in"

    it "redirect to the paper's edit page" do
      do_request
      expect(response.status).to eq(204)
    end

    it "passes the uploaded file's path to the document parser" do
      do_request
      expect(OxgarageParser).to have_received(:parse).with(uploaded_file.path)
    end

    it "updates the paper's title" do
      do_request
      expect(paper.reload.title).to eq 'This is a Title About Turtles'
    end

    it "updates the paper's body" do
      do_request
      expect(paper.reload.body).to eq "Heroes in a half shell! Turtle power!"
    end
  end
end
