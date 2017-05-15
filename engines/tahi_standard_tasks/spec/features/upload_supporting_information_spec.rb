require 'rails_helper'

feature "Upload Supporting Information", js: true do
  let(:author) { create :user }
  let!(:paper) do
    FactoryGirl.create :paper_with_task,
      :with_integration_journal,
      creator: author,
      task_params: {
        title: "Supporting Info",
        type: "TahiStandardTasks::SupportingInformationTask"
      }
  end

  before do
    login_as(author, scope: :user)
    visit "/"
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

    task.file_label_input = 'F4'
    task.file_category_dropdown = 'Figure'
    task.toggle_file_striking_image
    task.toggle_for_publication

    task.save_file_info
    wait_for_ajax

    paper.reload
    file = paper.supporting_information_files.last

    expect(file.label).to eq 'F4'
    expect(file.category).to eq 'Figure'
    expect(file.striking_image).to be(true)
    expect(file.publishable).to be(false)

    # delete file
    task.delete_file
    expect(task).to_not have_selector('.si-file')
  end

  scenario "Author is presented error" do
    supporting_info_task = paper.tasks.first

    # upload file
    task = Page.view_task_overlay(paper, supporting_info_task)
    task.attach_supporting_information
    expect(task).to have_no_content('Loading')
    expect(task).to have_no_content('Upload Complete!')
    expect(task).to have_file 'yeti.jpg'

    # edit file
    task.edit_file_info

    task.save_file_info

    expect(task.error_message).to match(/Please edit/)
  end

  scenario "Author uploads a broken file and sees error" do
    supporting_info_task = paper.tasks.first

    # upload file
    task = Page.view_task_overlay(paper, supporting_info_task)
    task.attach_bad_supporting_information
    expect(task).to have_no_content('Loading')
    expect(task).to have_no_content('Upload Complete!')

    expect(task.file_error_message).to have_content('There was an error while processing bad_yeti.tiff. Please try again or contact Aperta staff.')

    task.dismiss_file_error
    expect(task).to_not have_selector('.si-file-error')
  end
end
