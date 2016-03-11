require 'rails_helper'

feature 'Assign team', js: true do
  let!(:journal) do
    FactoryGirl.create(:journal, :with_roles_and_permissions)
  end
  let!(:paper) { FactoryGirl.create(:paper, :with_creator, journal: journal) }
  let!(:user) { FactoryGirl.create(:user) }
  let!(:internal_editor) do
    FactoryGirl.create(:user).tap do |editor|
      editor.assignments.create!(
        assigned_to: journal,
        role: journal.internal_editor_role
      )
    end
  end
  let!(:assign_team_task) do
    FactoryGirl.create(:assign_team_task, paper: paper)
  end

  scenario "User with permission can view and assign user to paper" do
    # User without permission cannot view the assign team task
    user.assignments.create!(
      assigned_to: paper,
      role: journal.creator_role
    )

    login_as(user, scope: :user)
    visit "/papers/#{assign_team_task.paper.id}/tasks/#{assign_team_task.id}"
    expect(page).to have_content("You don't have access to that content")

    # User with permission(s) can view and use the assign team task
    user.assignments.create!(
      assigned_to: paper,
      role: journal.handling_editor_role
    )
    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.assign_role_to_user journal.cover_editor_role.name, internal_editor
      expect(overlay).to have_content("#{internal_editor.full_name} has been assigned as #{journal.cover_editor_role.name}")
    end
  end
end
