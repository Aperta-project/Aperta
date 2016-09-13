require 'rails_helper'

feature "Invite Academic Editor", js: true do
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
  let(:paper) do
    FactoryGirl.create(
      :paper, :submitted_lite, :with_creator, journal: journal
    )
  end
  let(:task) { FactoryGirl.create :paper_editor_task, paper: paper }

  let(:staff_admin) { create :user }
  let!(:editor1) { create :user, first_name: 'Henry' }
  let!(:editor2) { create :user, first_name: 'Henroff' }
  let!(:editor3) { create :user, first_name: 'Henrietta' }

  before do
    assign_journal_role journal, staff_admin, :admin
    login_as(staff_admin, scope: :user)
    visit "/"
  end

  scenario "Staff Admin can invite any user as an academic editor on a paper" do
    overlay = Page.view_task_overlay(paper, task)
    overlay.paper_editors = [editor1]
    expect(overlay).to have_editors editor1.full_name

    expect(page).to have_css('.auto-suggest-item', text: editor3.full_name)
  end
end
