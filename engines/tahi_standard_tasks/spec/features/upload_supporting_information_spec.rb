require 'rails_helper'

feature "Upload Supporting Information", js: true do
  let(:author) { create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      :with_integration_journal,
      creator: author,
      task_params: {
        title: "Supporting Info",
        old_role: "author",
        type: "TahiStandardTasks::SupportingInformationTask"
      }
  end

  before do
    login_as(author, scope: :user)
    visit "/"

    allow(DownloadAttachmentWorker).to receive(:perform_async) do |supporting_info_id, url|
      supporting_info = SupportingInformationFile.find(supporting_info_id)
      supporting_info.save
    end

    click_link paper.title
  end

  scenario "Author uploads supporting information" do
    supporting_info_task = paper.tasks.first

    # upload file
    task = Page.view_task_overlay(paper, supporting_info_task)
    task.attach_supporting_information
    expect(task).to have_no_content('Loading')
    expect(task).to have_no_content('Upload Complete!')
    expect(task).to have_file 'yeti.jpg'

    # edit file
    task.edit_file_info

    task.file_title_input = 'new_file_title'
    task.file_caption_input = 'New file caption'
    task.file_label_input = 'F4'
    task.file_category_dropdown = 'Figure'
    task.toggle_file_striking_image
    task.toggle_for_publication

    task.save_file_info

    expect(task.file_title).to eq 'F4 Figure. new_file_title'
    expect(task.file_caption).to eq 'New file caption'

    paper.reload
    file = paper.supporting_information_files.last

    expect(file.title).to eq 'new_file_title'
    expect(file.caption).to eq 'New file caption'
    expect(file.label).to eq 'F4'
    expect(file.category).to eq 'Figure'
    expect(file.striking_image).to be(true)
    expect(file.publishable).to be(false)

    # delete file
    task.delete_file
    expect(task).to_not have_selector('.si-file')
  end
end
