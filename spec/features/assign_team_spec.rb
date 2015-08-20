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

  let!(:assign_team_task) { FactoryGirl.create(:assign_team_task, phase: paper.phases.first) }

  scenario "Journal admin can assign a user with a journal role to a paper" do
    custom_reviewer_role_name = custom_reviewer.roles.first.name

    login_as journal_admin

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.select2 custom_reviewer_role_name, from: "Role"
      wait_for_ajax

      overlay.select2 custom_reviewer.full_name, from: "User"
      wait_for_ajax

      click_button "Assign"

      expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
    end
  end

  scenario "A user who can view all manuscript managers can assign members to a paper" do
    custom_reviewer_role_name = custom_reviewer.roles.first.name

    login_as journal_editor

    AssignTeamOverlay.visit(assign_team_task)
    expect(page).to have_content("You don't have access to that content")

    journal_editor.roles.first.update_attribute :can_view_all_manuscript_managers, true
    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.select2 custom_reviewer_role_name, from: "Role"
      wait_for_ajax

      overlay.select2 custom_reviewer.full_name, from: "User"
      wait_for_ajax

      click_button "Assign"

      expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
    end
  end

  scenario "A user who can view assigned manuscript managers can assign members on a paper they themselves are assigned to" do
    custom_reviewer_role_name = custom_reviewer.roles.first.name
    journal_editor.roles.first.update_attribute :can_view_assigned_manuscript_managers, true

    login_as journal_editor

    AssignTeamOverlay.visit(assign_team_task)
    expect(page).to have_content("You don't have access to that content")
    DashboardPage.new.sign_out

    #
    # assign user
    #
    login_as journal_admin

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.select2 "Editor", from: "Role"
      wait_for_ajax

      overlay.select2 journal_editor.full_name, from: "User"
      wait_for_ajax

      click_button "Assign"

      expect(overlay).to have_content("#{journal_editor.full_name} has been assigned as Editor")
    end

    DashboardPage.new.sign_out

    #
    # Log in and verify
    #
    login_as journal_editor

    AssignTeamOverlay.visit(assign_team_task) do |overlay|
      overlay.select2 custom_reviewer_role_name, from: "Role"
      wait_for_ajax

      overlay.select2 custom_reviewer.full_name, from: "User"
      wait_for_ajax

      click_button "Assign"

      expect(overlay).to have_content("#{custom_reviewer.full_name} has been assigned as #{custom_reviewer_role_name}")
    end
  end
end
