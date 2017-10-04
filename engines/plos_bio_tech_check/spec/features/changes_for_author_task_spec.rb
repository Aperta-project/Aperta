require 'rails_helper'

feature 'Changes For Author', js: true do
  let(:author) { create :user }
  let(:paper) { create :paper, :checking, journal: journal, creator: author }
  let(:task) { create :changes_for_author_task, paper: paper }
  let(:journal) { create :journal, :with_roles_and_permissions }

  scenario "paper is editable but not submittable" do
    login_as(author)
    overlay = Page.view_task_overlay(paper, task)
    overlay.find("button#submit-tech-fix").click
  end
end
