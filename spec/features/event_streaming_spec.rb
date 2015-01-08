require 'rails_helper'

feature "Event streaming", js: true, selenium: true do
  let!(:author) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, creator: author, journal: journal }
  let(:upload_task) { paper.tasks_for_type(UploadManuscript::UploadManuscriptTask).first }
  let(:text_body) { { type: "text", value: "Hi there!" } }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author
  end

  describe "manuscript manager" do
    before do
      edit_paper = EditPaperPage.visit paper
      edit_paper.visit_task_manager
    end

    let(:submission_phase) { paper.phases.find_by_name("Submission Data") }

    scenario "creating a new task" do
      submission_phase.tasks.create title: "Wicked Awesome Card", type: "Task", body: text_body, role: "admin"

      phase = all('.column').detect {|p| p.find('h2').text == "Submission Data" }
      within phase do
        expect(page).to have_content "Wicked Awesome Card"
      end
    end

    scenario "deleting a task" do
      deleted_task = submission_phase.tasks.first.destroy!

      phase = all('.column').detect { |p| p.find('h2').text == "Submission Data" }
      within phase do
        expect(page).to_not have_content deleted_task.title
      end
    end
  end

  describe "tasks" do
    describe "updating completion status" do
      scenario "on the overlay" do
        edit_paper = EditPaperPage.visit paper
        edit_paper.view_card('Upload Manuscript')
        expect(page).to have_css("#task_completed:not(:checked)")
        upload_task.completed = true
        upload_task.save
        expect(page).to have_css("#task_completed:checked")
      end

      scenario "on the edit paper page" do
        EditPaperPage.visit paper
        expect(page).to have_no_selector(".completed")
        upload_task.completed = true
        upload_task.save
        expect(page).to have_css(".card--completed", count: 1)
      end
    end
  end

  describe "comments" do
    scenario "adding new comment" do
      edit_paper = EditPaperPage.visit paper
      edit_paper.view_card('Upload Manuscript')
      upload_task.comments.create(body: "This is my comment", commenter_id: create(:user).id)
      CommentLookManager.sync_task(upload_task)
      within '.message-comments' do
        expect(page).to have_css('.message-comment.unread', text: "This is my comment")
      end
    end
  end

  describe "paper roles" do

    let(:another_paper) { FactoryGirl.create(:paper, journal: journal) }

    before do
      DashboardPage.visit
      another_paper.paper_roles.collaborators.create(user: author)
    end

    scenario "adding a collaborator" do
      expect(page).to have_text(another_paper.title)
    end

    scenario "removing a collaborator" do
      another_paper.paper_roles.collaborators.where(user: author).destroy_all
      expect(page).to_not have_text(another_paper.title)
    end
  end

  describe "participations" do

    let(:another_paper) { FactoryGirl.create(:paper, journal: journal) }
    let(:task) { FactoryGirl.create(:task, paper: another_paper) }

    before do
      DashboardPage.visit
      another_paper.paper_roles.participants.create(user: author)
    end

    context "when not already associated to the paper" do

      scenario "added as a participant" do
        task.participants << author
        expect(page).to have_text(another_paper.title)
      end
    end

    context "when associated as a participant" do

      scenario "removes last participation" do
        another_paper.paper_roles.participants.destroy_all
        expect(page).to_not have_text(another_paper.title)
      end
    end
  end
end
