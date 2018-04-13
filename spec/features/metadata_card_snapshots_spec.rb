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

feature "Submitting a paper", js: true do
  let(:admin) { create :user, :site_admin }
  let(:journal) { FactoryGirl.create(:journal, :with_roles_and_permissions) }
  let!(:paper) do
    FactoryGirl.create(:paper_with_phases, creator: admin, journal: journal)
  end
  let!(:competing_interests_task) do
    FactoryGirl.create(
      :competing_interests_task,
      completed: true,
      paper: paper,
      phase_id: paper.phases.first.id
    )
  end

  before do
    login_as(admin, scope: :user)
  end

  scenario "snapshots its metadata cards" do
    visit "/"
    click_link paper.title
    paper_page = PaperPage.new

    paper_page.submit(&:submit)

    snapshot = Snapshot.where(source: competing_interests_task).first
    expect(snapshot).to be
    expect(snapshot.paper).to eq(paper)
    expect(snapshot.major_version).to eq(0)
    expect(snapshot.minor_version).to eq(0)
  end
end
