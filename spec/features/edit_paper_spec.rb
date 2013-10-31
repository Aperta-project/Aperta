require 'spec_helper'

feature "Editing paper" do
  include Warden::Test::Helpers
  Warden.test_mode!

  scenario "Author edits paper" do
    author = User.create! first_name: "Albert",
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      affiliation: 'Universität Zürich'
    login_as(author, scope: :user)

    paper = author.papers.create!

    edit_paper = EditSubmissionPage.visit paper
    edit_paper.short_title = "lorem-ipsum"
    edit_paper.title = "Lorem Ipsum Dolor Sit Amet"
    edit_paper.abstract = "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
    edit_paper.body = "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"

    dashboard_page = edit_paper.save
    expect(dashboard_page.submissions).to include 'lorem-ipsum'

    edit_paper = dashboard_page.edit_submission 'lorem-ipsum'
    expect(edit_paper.title).to eq "Lorem Ipsum Dolor Sit Amet"
    expect(edit_paper.abstract).to eq "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s,"
    expect(edit_paper.body).to eq "Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of \"de Finibus Bonorum et Malorum\" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum"
  end
end
