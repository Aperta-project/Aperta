require "rails_helper"

feature "Profile Page", js: true, vcr: {cassette_name: "ned_countries", record: :none} do
  include AuthorizationSpecHelper

  let(:admin) { create :user, :site_admin }
  let(:profile_page) { ProfilePage.new }

  before do
    assign_user admin, to: admin, with_role: Role.find_by(name: Role::USER_ROLE)
    login_as(admin, scope: :user)
    visit "/profile"
  end

  scenario "the page contains user's info if user is signed in" do
    expect(profile_page).to have_full_name(admin.full_name)
    expect(profile_page).to have_username(admin.username)
    expect(profile_page).to have_email(admin.email)
  end

  scenario "affiliation errors are handled" do
    profile_page.start_adding_affiliate
    profile_page.submit
    expect(page).to have_content(/can't be blank/i)
    expect(profile_page).to have_no_application_error
  end

  describe "canceling affiliation creation" do
    before do
      profile_page.start_adding_affiliate
    end

    it "hides the form" do
      expect(page).to have_css(".profile-affiliations-form")
      find("a", text: "cancel").click
      expect(page).to have_no_css(".profile-affiliations-form")
    end

    it "clears the form" do
      profile_page.fill_in_email("foo")
      find("a", text: "cancel").click
      find("a", text: "ADD NEW AFFILIATION").click
      expect(page).to have_no_content("foo")
    end
  end

  context "removing an affiliation" do

    let(:admin) { create :user, :with_affiliation, :site_admin }
    let(:affiliation) { admin.affiliations.last }

    scenario "user can delete an affiliation", selenium: true do
      profile_page.remove_affiliate(affiliation.name)
      expect(page).to have_no_content(/#{affiliation.name}/)
    end
  end
end
