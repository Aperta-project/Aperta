require 'rails_helper'

feature "Search Users on Admin Dashboard", js: true do
  let(:user) { create :user, :site_admin, first_name: "Test", last_name: "User", username: "testuser" }
  let!(:journal) { create :journal, :with_roles_and_permissions }

  before do
    create :user, first_name: "Bob", last_name: "Merlyn", username: 'shadow_missing2010'
    create :user, first_name: "Jim", last_name: "Bobit", username: 'jim'
    create :user, first_name: "Sam", last_name: "Smith", username: 'bobby'
    create :user, first_name: "Jane", last_name: "Doe", username: 'janny'

    login_as(user, scope: :user)
    visit "/"
  end

  let(:admin_page) { AdminDashboardPage.visit }

  scenario "Searching users returns a list of users" do
    admin_page.search("bob")
    search_results = admin_page.search_results

    expect(search_results.length).to eq(3)
    expect(search_results).to match_array(
      [{ first_name: "Bob", last_name: "Merlyn", username: 'shadow_missing2010' },
       { first_name: "Jim", last_name: "Bobit", username: 'jim' },
       { first_name: "Sam", last_name: "Smith", username: 'bobby' }])
  end
end
