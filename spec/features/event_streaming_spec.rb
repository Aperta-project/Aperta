require 'rails_helper'

feature "Event streaming", js: true, selenium: true, sidekiq: :inline! do

  context "as an admin" do
    let!(:admin) { FactoryGirl.create :user, :site_admin }
    let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions }
    let!(:paper) do
      FactoryGirl.create :paper, :with_tasks, creator: admin, journal: journal
    end
    let(:text_body) { { type: "text", value: "Hi there!" } }

    before do
      login_as(admin, scope: :user)
      visit "/"
    end

    context "on the workflow page" do
      before do
        click_link(paper.title)
        click_link("Workflow")
      end

      let(:submission_phase) { paper.phases.find_by_name("Submission Data") }

      scenario "managing tasks" do
        # create
        submission_phase.tasks.create(
          title: "Wicked Awesome Card",
          type: "Task",
          body: text_body,
          old_role: "admin",
          paper: submission_phase.paper
        )
        wait_for_ajax
        expect(page).to have_content "Wicked Awesome Card"

        # destroy
        deleted_task = submission_phase.tasks.first.destroy!
        wait_for_ajax
        expect(page).to_not have_content deleted_task.title
      end
    end

    context "on the dashboard page" do
      let!(:collaborator_paper) { FactoryGirl.create(:paper, journal: journal) }
      let!(:participant_paper) { FactoryGirl.create(:paper, journal: journal) }

      scenario "access to papers" do
        # added as a collaborator
        collaborator_paper.add_collaboration(admin)
        collaborator_paper.paper_roles.collaborators.create(user: admin)
        expect(page).to have_text(collaborator_paper.title)

        # removed as a collaborator
        collaborator_paper.remove_collaboration(admin)
        collaborator_paper.paper_roles.collaborators.where(user: admin).destroy_all
        expect(page).to_not have_text(collaborator_paper.title)

        # added as a task participant
        participant_paper.assignments.create!(
          user: admin,
          role: participant_paper.journal.task_participant_role
        )
        participant_paper.paper_roles.participants.create(user: admin)
        expect(page).to have_text(participant_paper.title)

        # removed as a task participant
        participant_paper.assignments.find_by!(
          user: admin,
          role: participant_paper.journal.task_participant_role
        ).destroy
        participant_paper.paper_roles.participants.find_by(user: admin).destroy
        expect(page).to_not have_text(participant_paper.title)
      end
    end
  end
end
