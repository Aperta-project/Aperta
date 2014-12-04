require 'spec_helper'

feature "Profile Page", js: true do
  let(:admin) { create :user, :site_admin }
  let(:profile_page) { ProfilePage.visit }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "the page contains user's info if user is signed in" do
    expect(profile_page).to have_full_name(admin.full_name)
    expect(profile_page).to have_username(admin.username)
    expect(profile_page).to have_email(admin.email)
    profile_page.sign_out
    expect(current_path).to eq new_user_session_path
  end

  scenario "affiliation errors are handled" do
    profile_page.start_adding_affiliate
    profile_page.submit
    expect(page).to have_content(/name can't be blank/i)
    expect(profile_page).to have_no_application_error
  end

  scenario "user can delete an affiliation", selenium: true do
    admin.affiliations.create(name: 'Yoda University')
    profile_page.remove_affiliate('Yoda University')
    expect(page).to have_no_content(/Yoda University/)
  end

  describe "canceling affiliation creation" do
    before do
      profile_page.start_adding_affiliate
    end

    it "hides the form" do
      expect(page).to have_css('.profile-affiliations-form')
      find('a', text: 'cancel').click
      expect(page).to have_no_css('.profile-affiliations-form')
    end

    it "clears the form" do
      profile_page.fill_in_email("foo")
      find('a', text: 'cancel').click
      find('a', text: 'ADD NEW AFFILIATION').click
      expect(page).to have_no_content("foo")
    end
  end
end
