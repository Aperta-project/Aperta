require 'rails_helper'

feature "Upload Supporting Information", js: true, selenium: true do
  let(:author) { create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      creator: author,
      task_params: {
        title: "Supporting Info",
        role: "author",
        type: "TahiStandardTasks::SupportingInformationTask"
      }
  end


  before do
    sign_in_page = SignInPage.visit
    sign_in_page.sign_in author

    allow(DownloadSupportingInfoWorker).to receive(:perform_async) do |supporting_info_id, url|
      supporting_info = SupportingInformationFile.find(supporting_info_id)
      supporting_info.save
    end

    click_link paper.title
  end

  scenario "Author uploads supporting information" do
    edit_paper = EditPaperPage.new

    # upload file
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      overlay.attach_supporting_information
      expect(overlay).to have_no_content('Loading')
      expect(overlay).to have_no_content('Upload Complete!')
      expect(overlay).to have_file 'yeti.jpg'
    end

    # edit file
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

    # delete file
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      find('.attachment-thumbnail').hover
      find('.fa-trash').click
      find('.attachment-delete-button').click
      expect(overlay).to_not have_selector('.attachment-image')
    end
  end
end
