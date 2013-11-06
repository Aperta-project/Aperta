require 'spec_helper'

feature "Editing paper", js: true do
  include ActionView::Helpers::JavaScriptHelper

  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  let(:paper) { paper = author.papers.create! short_title: 'foo bar' }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "Author edits paper" do
    edit_paper = EditSubmissionPage.visit paper
    edit_paper.short_title = "lorem-ipsum"
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.abstract = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
    edit_paper.body = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"

    dashboard_page = edit_paper.save
    DashboardPage.visit
    expect(dashboard_page.submissions).to include 'lorem-ipsum'

    edit_paper = EditSubmissionPage.visit paper
    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    expect(edit_paper.abstract).to match /Lorem Ipsum is simply dummy text/
    expect(edit_paper.body).to eq "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"
  end

  scenario "Author uploads paper in Word format" do
    edit_paper = EditSubmissionPage.visit paper

    edit_paper.upload_word_doc
    expect(edit_paper.title).to eq "This is a Title About Turtles"
    expect(edit_paper.body).to match /And this is my subtitle/
  end
end
