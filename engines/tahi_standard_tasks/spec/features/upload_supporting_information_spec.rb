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
    login_as author
    visit "/"

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
      find('.attachment-thumbnail .edit-icons .fa-pencil').click
      title = find('.attachment-thumbnail .edit-info input[type=text]')
      caption = find('.attachment-thumbnail .edit-info textarea')

      title.set 'new_file_title'
      caption.set 'New file caption'
      find('.attachment-thumbnail .edit-info .button-primary').click

      expect(find('.attachment-thumbnail .info .title').text).to eq 'new_file_title'
      expect(find('.attachment-thumbnail .info .caption').text).to eq 'New file caption'
    end

    file = paper.supporting_information_files.last
    expect(file.title).to eq 'new_file_title'
    expect(file.caption).to eq 'New file caption'

    # edit publishable state
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      expect(file.publishable).to eq true
      overlay.publishable_checkbox.click
      wait_for_ajax
    end
    visit current_path
    expect(file.reload.publishable).to eq false

    # delete file
    edit_paper.view_card('Supporting Info', SupportingInformationOverlay) do |overlay|
      find('.attachment-thumbnail').hover
      find('.fa-trash').click
      find('.attachment-delete-button').click
      expect(overlay).to_not have_selector('.attachment-image')
    end
  end
end
