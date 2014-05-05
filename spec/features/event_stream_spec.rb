require 'spec_helper'

feature "Event streaming", js: true do
  let!(:author) { FactoryGirl.create :user, :admin }
  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }
  let(:upload_task) { author.papers.first.tasks_for_type(UploadManuscriptTask).first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "On the dashboard page" do
    expect(page).to have_css(".dashboard-header")
    expect(page).to have_no_selector(".completed")
    upload_task.completed = true
    upload_task.save
    expect(page).to have_css(".card-completed", count: 1)
  end

  describe "manuscript manager" do
    before do
      edit_paper = EditPaperPage.visit paper
      edit_paper.visit_task_manager
    end

    let(:submission_phase) { paper.phases.find_by_name("Submission Data") }

    scenario "creating a new message task" do
      mt = submission_phase.tasks.new title: "Wicked Message Card", type: "MessageTask", body: "Hi there!", role: "user"
      mt.participants << author
      mt.save!

      phase = all('.column').detect {|p| p.find('h2').text == "Submission Data" }
      within phase do
        expect(page).to have_content "Wicked Message Card"
      end
    end

    scenario "creating a new task" do
      submission_phase.tasks.create title: "Wicked Awesome Card", type: "Task", body: "Hi there!", role: "admin"

      phase = all('.column').detect {|p| p.find('h2').text == "Submission Data" }
      within phase do
        expect(page).to have_content "Wicked Awesome Card"
      end
    end
  end

  describe "message tasks" do
    before do
      edit_paper = EditPaperPage.visit paper
      edit_paper.visit_task_manager
      submission_phase = paper.phases.find_by_name("Submission Data")
      @mt = submission_phase.tasks.new title: "Wicked Message Card", type: "MessageTask", body: "Hi there!", role: "user"
      @mt.participants << author
      @mt.save!
      find('.card-content', text: "Wicked Message Card").click
      expect(page).to have_css(".overlay-content")
    end

    scenario "marking complete" do
      expect(page).to have_css("#task_completed:not(:checked)")
      @mt.completed = true
      @mt.save
      expect(page).to have_css("#task_completed:checked")
    end

    scenario "adding new comments" do
      @mt.comments.create body: "Hey-o", commenter_id: author.id
      within '.message-comments' do
        expect(page).to have_content "Hey-o"
      end
    end

    scenario "adding new participants" do
      @mt.participants << FactoryGirl.create(:user)
      @mt.save
      expect(all('.user-thumbnail').count).to eq(2)
    end
  end

  describe "tasks" do
    scenario "enter declarations" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card('Enter Declarations')
      expect(page).to have_css(".overlay-content")
      survey = Survey.first
      survey.answer = "Hello!"
      survey.save
      expect(all('textarea').map(&:value)).to include("Hello!")
    end

    scenario "marking a task completed" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card('Upload Manuscript')
      expect(page).to have_css("#task_completed:not(:checked)")
      upload_task.completed = true
      upload_task.save
      expect(page).to have_css("#task_completed:checked")
    end
  end

  scenario "On the edit paper page" do
    EditPaperPage.visit paper
    expect(page).to have_no_selector(".completed")
    upload_task.completed = true
    upload_task.save
    expect(page).to have_css(".card-completed", count: 1)
  end

end
