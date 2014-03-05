require 'spec_helper'

feature "Displaying task", js: true do
  let(:admin) do
    User.create! username: 'zoey',
      first_name: 'Zoey',
      last_name: 'Bob',
      email: 'hi@example.com',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'PLOS',
      admin: true
  end


  let(:author) do
    User.create! username: 'albert',
      first_name: 'Albert',
      last_name: 'Einstein',
      email: 'einstein@example.org',
      password: 'password',
      password_confirmation: 'password',
      affiliation: 'Universität Zürich'
  end

  let!(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create!, user: author }

  let(:task) { Task.where(title: "Assign Admin").first }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin.email
  end

  scenario "User visits task's show page" do
    assign_admin_overlay = CardOverlay.visit [task.paper, task]
    expect(assign_admin_overlay).to_not be_completed

    assign_admin_overlay.mark_as_complete
    assign_admin_overlay.reload

    expect(assign_admin_overlay).to be_completed
  end

end
