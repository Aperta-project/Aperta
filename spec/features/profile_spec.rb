require 'spec_helper'

feature "Profile Page", js: true do
  let(:admin) { create :user, admin: true }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in admin
  end

  scenario "the page contains user's info if user is signed in" do
    profile_page = ProfilePage.visit
    expect(profile_page.full_name).to eq admin.full_name
    expect(profile_page.username).to eq admin.username
    expect(profile_page.email).to eq admin.email
    expect(profile_page.affiliations).to match_array admin.affiliations.to_a

    find('a.dropdown-toggle').click
    click_on 'Sign out'
    expect(current_path).to eq new_user_session_path
  end

  scenario "user can upload an avatar image" do
    profile_page = ProfilePage.visit
    profile_page.attach_image('yeti.jpg')
    expect(profile_page.image).to eq('yeti.jpg')
    expect(profile_page.image_size).to eq('160x160')

    profile_page.reload
    expect(profile_page.image).to eq('yeti.jpg')
    expect(profile_page.image_size).to eq('160x160')
  end

  scenario "user cannot upload an avatar image of unsupported type" do
    profile_page = ProfilePage.visit
    profile_page.attach_image('about_turtles.docx')
    expect(profile_page.image).to_not eq('about_turtles.docx')
    expect(profile_page.image).to eq('profile-no-image.png')

    profile_page.reload
    expect(profile_page.image).to_not eq('about_turtles.docx')
    expect(profile_page.image).to eq('profile-no-image.png')
  end

  scenario "user can add an affiliation" do
    profile_page = ProfilePage.visit
    profile_page.add_affiliate('Yoda University')
    expect(profile_page.affiliations).to include(/Yoda/)

    profile_page.reload
    expect(profile_page.affiliations).to include(/Yoda/)
  end

  scenario "affiliation errors are handled" do
    profile_page = ProfilePage.visit
    profile_page.add_affiliate(' ')
    expect(page).to have_content /name can't be blank/i
  end

  scenario "user can delete an affiliation" do
    profile_page = ProfilePage.visit
    profile_page.add_affiliate('Yoda University')
    profile_page.remove_affiliate('Yoda University')
    expect(page).to_not have_content(/Yoda University/)
  end

end
