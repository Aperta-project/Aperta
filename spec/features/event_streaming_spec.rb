# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'
require 'support/sidekiq_helper_methods'

feature "Event streaming", js: true, selenium: true, sidekiq: :inline! do
  context "as an admin" do
    let!(:admin) { FactoryGirl.create :user, :site_admin }
    let!(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
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
        visit "/papers/#{paper.id}"
        click_link("Workflow")
      end

      let(:submission_phase) { paper.phases.find_by_name("Submission Data") }

      scenario "managing tasks" do
        FactoryGirl.create(:ad_hoc_task,
                           title: "Wicked Awesome Card",
                           body: text_body,
                           phase: submission_phase,
                           paper: submission_phase.paper)

        expect(page).to have_content "Wicked Awesome Card"

        # destroy
        deleted_task = submission_phase.tasks.first.destroy!
        expect(page).not_to have_content deleted_task.title
      end
    end

    context "on the dashboard page" do
      let(:collaborator_paper) { FactoryGirl.create(:paper, journal: journal) }
      let(:participant_paper) { FactoryGirl.create(:paper, journal: journal) }

      scenario "access to papers" do
        # added as a collaborator
        collaborator_paper.add_collaboration(admin)
        wait_for_ajax
        expect(page).to have_text(collaborator_paper.title)

        # removed as a collaborator
        collaborator_paper.remove_collaboration(admin)
        wait_for_ajax
        expect(page).to have_no_content(collaborator_paper.title)

        # added as a task participant
        participant_paper.assignments.create!(
          user: admin,
          role: participant_paper.journal.task_participant_role
        )
        expect(page).to have_text(participant_paper.title)

        # removed as a task participant
        participant_paper.assignments.find_by!(
          user: admin,
          role: participant_paper.journal.task_participant_role
        ).destroy
        wait_for_ajax
        expect(page).not_to have_text(participant_paper.title)
      end
    end
  end
end
