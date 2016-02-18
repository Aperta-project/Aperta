require 'rails_helper'

feature 'Assign team', js: true do
  let!(:plos_journal) { create(:journal) }
  let!(:paper) { create(:paper_with_phases, journal: plos_journal, creator: author) }

  let!(:author) { create :user, first_name: "Albert", last_name: "Author" }

  let!(:journal_admin) do
    create(:user, first_name: "Journal", last_name: "Admin").tap do |admin|
      assign_journal_role(plos_journal, admin, :admin)
    end
  end

  let!(:journal_editor) do
    create(:user, first_name: "Journal", last_name: "Editor").tap do |editor|
      assign_journal_role(plos_journal, editor, :editor)
    end
  end

  let!(:custom_reviewer) do
    create(:user, first_name: "Custom", last_name: "Reviewer").tap do |reviewer|
      assign_journal_role(plos_journal, reviewer, :custom)
    end
  end

  let!(:assign_team_task) do
    FactoryGirl.create(
      :assign_team_task,
      paper: paper,
      phase: paper.phases.first
    )
  end

  scenario "Journal admin can assign a user with a journal old_role to a paper" do
    custom_reviewer_role_name = custom_reviewer.old_roles.first.name

    login_as(journal_admin, scope: :user)

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.assign_old_role_for_user custom_reviewer_role_name, custom_reviewer
      expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
    end
  end

  scenario "A user who cannot view the assign team task cannot view the overlay" do
    skip "need to revisit if this is valid with JIRA issue: APERTA-5648" do

      custom_reviewer_role_name = custom_reviewer.old_roles.first.name

      login_as(journal_editor, scope: :user)

      # Remove the ability to view task(s)
      view_task_permission = plos_journal.internal_editor_role.permissions
        .find_by!(action: 'view', applies_to: 'Task')
      plos_journal.internal_editor_role.permissions -= [view_task_permission]

      AssignTeamOverlay.visit(assign_team_task)
      expect(page).to have_content("You don't have access to that content")

      # Add back in the ability to view task(s)
      plos_journal.internal_editor_role.permissions += [view_task_permission]
      AssignTeamOverlay.visit(assign_team_task) do |overlay|
        overlay.assign_old_role_for_user custom_reviewer_role_name, custom_reviewer
        expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
      end
    end
  end

  scenario "A user who can view assigned manuscript managers can assign members on a paper they themselves are assigned to" do
    skip "need to revisit if this is valid with JIRA issue: APERTA-5648"

    custom_reviewer_role_name = custom_reviewer.old_roles.first.name
    journal_editor.old_roles.first.update_attribute :can_view_assigned_manuscript_managers, true

    login_as(journal_editor, scope: :user)

    AssignTeamOverlay.visit(assign_team_task)
    expect(page).to have_content("You don't have access to that content")
    Page.new.sign_out

    #
    # assign user
    #
    login_as(journal_admin, scope: :user)

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.assign_old_role_for_user "Editor", journal_editor
      expect(overlay).to have_content("#{journal_editor.full_name} has been assigned as Editor")
    end

    Page.new.sign_out

    #
    # Log in and verify
    #
    login_as(journal_editor, scope: :user)

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.assign_old_role_for_user custom_reviewer_role_name, custom_reviewer
      expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
    end
  end

  scenario "A user who can manage the manuscript can remove members on a paper they are assigned to" do
    assign_paper_role(paper, custom_reviewer, "editor")

    login_as(journal_admin, scope: :user)

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.unassign_user custom_reviewer
      expect(overlay).to_not have_content(custom_reviewer.full_name)

      overlay.reload
      expect(overlay).to_not have_content(custom_reviewer.full_name)
    end
  end
end
