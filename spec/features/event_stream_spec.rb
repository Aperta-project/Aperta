require 'spec_helper'

feature "Event streaming", js: true, selenium: true do
  let!(:author) { FactoryGirl.create :user, :site_admin }
  let!(:journal) { FactoryGirl.create :journal }
  let!(:paper) { FactoryGirl.create :paper, :with_tasks, user: author, journal: journal }
  let(:upload_task) { paper.tasks_for_type(UploadManuscript::Task).first }
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

    scenario "creating a new message task" do
      mt = submission_phase.tasks.new title: "Wicked Message Card", type: "MessageTask", body: text_body, role: "user"
      mt.save!

      phase = all('.column').detect {|p| p.find('h2').text == "Submission Data" }
      within phase do
        expect(page).to have_content "Wicked Message Card"
      end
    end

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

  describe "message tasks" do
    before do
      submission_phase = paper.phases.find_by_name("Submission Data")
      @mt = submission_phase.tasks.new title: "Wicked Message Card", type: "MessageTask", body: text_body, role: "user"
      @mt.participants << author
      @mt.save!
      TaskManagerPage.visit paper
      find('.card-content', text: "Wicked Message Card").click
      expect(page).to have_css(".overlay-content")
    end

    scenario "adding new comments" do
      @mt.comments.create({body: "This is my comment", commenter_id: create(:user).id})
      CommentLookManager.sync_task(@mt)
      within '.message-comments' do
        expect(page).to have_css('.message-comment.unread', text: "This is my comment")
      end
    end
  end

  describe "tasks" do
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
    expect(page).to have_css(".card--completed", count: 1)
  end

end
