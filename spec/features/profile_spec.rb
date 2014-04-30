require 'spec_helper'

feature "Profile Page", js: true do
  let(:admin) { create :user }

  context "signed in" do
    before do
      sign_in_page = SignInPage.visit
      sign_in_page.sign_in admin.email
    end

    scenario "the page contains user's info" do
      profile_page = ProfilePage.visit
      expect(profile_page.user_full_name).to eq admin.full_name
      expect(profile_page.username).to eq admin.username
      expect(profile_page.email).to eq admin.email
    end
  end
end
