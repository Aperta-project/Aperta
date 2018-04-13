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
require 'support/pages/task_manager_page'

feature 'Comments on cards', js: true do
  let(:admin) { create :user, :site_admin, first_name: "Admin" }
  let(:albert) { create :user, first_name: "Albert" }
  let!(:paper) do
    FactoryGirl.create(
      :paper_with_phases,
      :with_integration_journal,
      :submitted,
      creator: admin
    )
  end

  before do
    login_as(admin, scope: :user)
    visit "/"
  end

  describe "being made aware of commenting" do
    let!(:task) do
      FactoryGirl.create(
        :ad_hoc_task,
        type: 'AdHocTask',
        paper: paper,
        phase: paper.phases.first,
        participants: [admin, albert]
      )
    end

    before do
      task.comments.create(commenter: albert, body: "Lorem\nipsum dolor\nsit amet")
      CommentLookManager.sync_task(task)
      click_link paper.title
      find('#nav-workflow').click
    end

    scenario "displays the number of unread comments as badge on task" do
      page = TaskManagerPage.new
      expect(page.tasks.first.unread_comments_badge).to eq(1)
    end

    scenario "breaks text at newlines" do
      page = TaskManagerPage.new
      find('.card-title').click
      # This is checking to see that there are indeed three seperate lines of text
      expect(page.find('.comment-body').native.text.split("\n").count).to eq 3
    end
  end
end
