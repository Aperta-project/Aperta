require 'spec_helper'

feature "Displays Task Manager", js: true do
  include ActionView::Helpers::JavaScriptHelper

  let(:admin) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich',
      admin: true
  end

  let(:paper) do
    paper = admin.papers.create!(
                  short_title: 'foobar',
                  title: 'Foo bar',
                  journal: Journal.create!)
  end

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario "Admin can see the task manager" do
    edit_paper = EditSubmissionPage.visit paper
    task_manager = edit_paper.navigate_to_task_manager
    expect(task_manager.phases).to include 'Needs Editor'
    expect(task_manager.phases).to include 'Needs Reviewer'

    edit_paper = task_manager.navigate_to_edit_paper
    expect(edit_paper.title).to eq "Foo bar"
  end
end
