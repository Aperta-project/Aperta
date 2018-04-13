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
require 'support/pages/overlays/assign_team_overlay'

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

    Page.new.sign_out

    # Internal Editor logs in and sees they have the CoverEditor role
    # on the paper
    login_as(internal_editor, scope: :user)
    visit '/'
    within "[data-test-id=dashboard-paper-#{paper.id}]" do
      expect(page).to have_content(paper.title)
      expect(page).to have_content(paper.journal.cover_editor_role.name)
    end
  end
end
