require 'spec_helper'

feature "Upload Supporting Information", js: true, selenium: true do
  let(:author) { create :user }
  let(:journal) { create :journal }
  let(:paper) { FactoryGirl.create :paper, :with_tasks, journal: journal, user: author }

  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author

    allow(SupportingInformation::DownloadSupportingInfoWorker).to receive(:perform_async) do |supporting_info_id, url|
      supporting_info = SupportingInformation::File.find(supporting_info_id)
      supporting_info.save
    end

  end

  scenario "Author uploads supporting information" do
    edit_paper = EditPaperPage.visit paper

    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      overlay.attach_supporting_information
      expect(overlay).to have_file 'yeti.jpg'
    end
  end

  scenario "Author destroys supporting information immediately" do
    edit_paper = EditPaperPage.visit paper
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      overlay.attach_supporting_information
      find('.attachment-thumbnail').hover
      find('.glyphicon-trash').click
      find('.attachment-delete-button').click
      expect(overlay).to_not have_selector('.attachment-image')
    end
  end

  scenario "Author can edit title and caption" do
    paper.supporting_information_files.create
    edit_paper = EditPaperPage.visit paper
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      find('.attachment-edit-icon').click
      title   = find('.attachment-thumbnail-edit-content input[type=text]')
      caption = find('.attachment-thumbnail-edit-content textarea')

      title.set 'new_file_title'
      caption.set 'New file caption'
      find('.attachment-thumbnail-edit-content .button-secondary').click

      expect(find('.attachment-thumbnail-title').text).to eq 'new_file_title'
      expect(find('.attachment-thumbnail-caption').text).to eq 'New file caption'
    end

    file = paper.supporting_information_files.last
    expect(file.title).to eq 'new_file_title'
    expect(file.caption).to eq 'New file caption'
  end
end
