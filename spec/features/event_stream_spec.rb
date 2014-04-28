require 'spec_helper'

# In general, updating database objects occurs faster than Ember transitions.
# Because of this I have littered sleeps throughout the code to make sure the
# transition finishes before asserting there was a UI update.
feature "Event streaming", js: true do
  let!(:author) { FactoryGirl.create :user }
  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create! }
  let(:upload_task) { author.papers.first.tasks_for_type(UploadManuscriptTask).first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "On the dashboard page" do
    # Weird race condition if this test doesn't run first.
    sleep 0.3
    expect(page).to have_no_selector(".completed")
    upload_task.completed = true
    upload_task.save
    expect(page).to have_css(".card-completed", count: 1)
  end

  describe "manuscript manager" do
    before do
      edit_paper = EditPaperPage.visit paper
      edit_paper.navigate_to_task_manager
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
      edit_paper.navigate_to_task_manager
      submission_phase = paper.phases.find_by_name("Submission Data")
      @mt = submission_phase.tasks.new title: "Wicked Message Card", type: "MessageTask", body: "Hi there!", role: "user"
      @mt.participants << author
      @mt.save!
      find('.card-content', text: "Wicked Message Card").click
    end

    scenario "marking complete" do
      checkbox = find("#task_completed")
      expect(checkbox).to_not be_checked
      @mt.completed = true
      @mt.save
      sleep 0.3
      expect(checkbox).to be_checked
    end
  end

  describe "tasks" do
    scenario "enter declarations" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card('Enter Declarations')
      sleep 0.3
      survey = Survey.first
      survey.answer = "Hello!"
      survey.save
      expect(all('textarea').map(&:value)).to include("Hello!")
    end

    scenario "marking a task completed" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card('Upload Manuscript')
      checkbox = find("#task_completed")
      expect(checkbox).to_not be_checked
      upload_task.completed = true
      upload_task.save
      sleep 0.3
      expect(checkbox).to be_checked
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
