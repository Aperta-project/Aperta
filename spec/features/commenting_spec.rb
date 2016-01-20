require 'rails_helper'

feature 'Comments on cards', js: true do
  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:albert) { create :user, first_name: "Albert" }
  let!(:paper) { FactoryGirl.create(:paper_with_phases, :submitted, creator: admin) }

  before do
    # Remove when site_admin has access to everything
    assign_author_role(paper, admin)
    login_as(admin, scope: :user)
    visit "/"
  end

  describe "being made aware of commenting" do
    let!(:task) do
      FactoryGirl.create(
        :task,
        paper: paper,
        phase: paper.phases.first,
        participants: [admin, albert]
      )
    end

    before do
      task.comments.create(commenter: albert, body: "Lorem\nipsum dolor\nsit amet")
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

    scenario "breaks text at newlines" do
      page = TaskManagerPage.new
      find('.card-content').click
      # This is checking to see that there are indeed three seperate lines of text
      expect(page.find('.comment-body').native.text.split("\n").count).to eq 3
    end
  end
end
