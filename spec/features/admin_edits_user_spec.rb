require 'rails_helper'

feature "Admin can edit user details and initiate password reset", js: true do
  let(:user) { create :user, :site_admin, first_name: "Test", last_name: "User", username: "testuser" }
  let!(:journal) { create :journal, :with_roles_and_permissions }
  let(:admin_page) { AdminDashboardPage.visit }

  before do
    create :user, first_name: "Bob", last_name: "Merlyn", username: 'shadow_missing2010'

    login_as(user, scope: :user)
    visit "/"

    within('.main-nav') do
      click_link 'Admin'
    end
  end

  scenario "Admin saves user details" do
    admin_page.search "bob"
    bob = admin_page.first_search_result
    edit_modal = bob.edit_user_details
    edit_modal.first_name = "Andy"
    edit_modal.last_name = "Plantenberg"
    edit_modal.username = "andy"

    admin_page = edit_modal.save
    admin_page.search("andy")
    search_results = admin_page.search_results

    expect(search_results.first[:first_name]).to eq("Andy")
    expect(search_results.first[:last_name]).to eq("Plantenberg")
    expect(search_results.first[:username]).to eq("andy")
  end

  scenario "Admin cancels user details after editing" do
    admin_page.search("bob")
    bob = admin_page.first_search_result
    edit_modal = bob.edit_user_details
    edit_modal.first_name = "Andy"
    edit_modal.last_name = "Plantenberg"
    edit_modal.username = "andy"

    admin_page = edit_modal.cancel
    admin_page.search("bob")
    search_results = admin_page.search_results

    expect(search_results.first[:first_name]).to eq("Bob")
    expect(search_results.first[:last_name]).to eq("Merlyn")
    expect(search_results.first[:username]).to eq("shadow_missing2010")
  end

  scenario "Admin initiates reset password" do
    admin_page.search("bob")
    bob = admin_page.first_search_result
    edit_modal = bob.edit_user_details
    edit_modal.reset_password

    expect(edit_modal.reset_password_status).to have_content(/reset password instructions has been sent/)
  end
end
