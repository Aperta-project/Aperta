require 'spec_helper'

include DownloadHelpers
feature "Download paper as ePub", js: false do
  let(:author) { FactoryGirl.create :user, admin: true }
  let(:paper) { author.papers.create! short_title: 'foo bar', journal: Journal.create!, submitted: true }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author.email
  end

  scenario "User downloads paper in ePub format" do
    PaperPage.visit paper
    click_link 'Download ePub'

    # binding.pry
  end
end
