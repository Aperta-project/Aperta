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

feature "Paper DOI Generation", selenium: true, js: true do
  let(:user) { FactoryGirl.create :user }

  context "As an author on the paper page" do
    before do
      assign_journal_role(journal, user, :admin)
      login_as(user, scope: :user)
      visit "/"
    end

    context "on a journal with a doi prefix set" do
      let(:journal) {
        FactoryGirl.create :journal, :with_roles_and_permissions, :with_default_mmt,
        doi_publisher_prefix: 'vicious',
        doi_journal_prefix: 'journal.robots',
        last_doi_issued: '8887'
      }

      let(:paper_type) {
        journal.manuscript_manager_templates.pluck(:paper_type).first
      }

      let!(:paper) {
        FactoryGirl.create(:paper, journal: journal, paper_type: paper_type)
      }

      scenario "shows the manuscript id (derived from doi) on the page" do
        visit "/papers/#{paper.id}"

        within ".task-list-doi" do
          expect(page).to have_content "Manuscript ID: robots.8888"
        end
      end
    end
  end
end
