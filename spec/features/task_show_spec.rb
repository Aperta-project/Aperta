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
require 'support/pages/card_overlay'

feature "Displaying task", js: true do
  let(:admin) { create :user, :site_admin }
  let(:task) { paper.tasks.first }
  let!(:paper) do
    FactoryGirl.create(:paper_with_task,
      :with_integration_journal,
      creator: admin,
      task_params: {
        type: 'AdHocTask',
        title: "Some Task"
      }
    )
  end

  before do
    login_as(admin, scope: :user)
    visit "/"
    click_link paper.title
    click_link "Workflow"
    find(".card-title", text: /#{task.title}/).click
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.new
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete

    expect(assign_admin_overlay).to be_completed
    expect(assign_admin_overlay).to have_no_application_error
  end
end
