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
require 'support/pages/paper_page'

feature "Adding collaborators", js: true do
  let(:author) { FactoryGirl.create :user }
  let(:journal) { FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt }
  let(:paper) do
    FactoryGirl.create :paper, :with_tasks, journal: journal, creator: author
  end
  let!(:user) { FactoryGirl.create :user }

  before do
    assign_journal_role(journal, author, :admin)
    login_as(author, scope: :user)
    visit "/papers/#{paper.id}"
  end

  scenario "Managing collaborators" do
    edit_paper = PaperPage.new
    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.add_collaborators(user)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Figures"

    collaborators_overlay = edit_paper.show_contributors
    expect(collaborators_overlay).to have_collaborators(user)

    collaborators_overlay = edit_paper.show_contributors
    collaborators_overlay.remove_collaborators(user)
    collaborators_overlay.save

    expect(edit_paper).to have_no_application_error
    expect(page).to have_content "Figures"

    collaborators_overlay = edit_paper.show_contributors
    expect(collaborators_overlay).to have_no_collaborator(user)
  end
end
