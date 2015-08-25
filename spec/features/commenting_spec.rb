require 'rails_helper'

feature 'Comments on cards', js: true do
  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:albert) { create :user, first_name: "Albert" }
  let!(:paper) { FactoryGirl.create(:paper_with_phases, :submitted, creator: admin) }

  before do
    login_as admin
    visit "/"
  end

  describe "being made aware of commenting" do
    let!(:task) { create :task, phase: paper.phases.first, participants: [admin, albert] }

    before do
      task.comments.create(commenter: albert, body: "<script>alert('DOOM')</script>")
      CommentLookManager.sync_task(task)
      click_link paper.title
      within ".control-bar" do
        click_link "Workflow"
      end
    end

    scenario "displays the number of unread comments as badge on task" do
      page = TaskManagerPage.new
      expect(page.tasks.first.unread_comments_badge).to eq(1)
    end

    scenario "displays user entered comment as non-escaped string" do
      page = TaskManagerPage.new
      find('.card-content').click
      expect(page).to have_content "#{task.comments.first.body}"
    end
  end
end
