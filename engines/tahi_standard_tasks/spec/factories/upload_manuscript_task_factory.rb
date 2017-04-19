FactoryGirl.define do
  factory :upload_manuscript_task, class: 'TahiStandardTasks::UploadManuscriptTask' do
    paper
    phase
    card_version
    title "Upload Manuscript"
  end
end
