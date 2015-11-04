FactoryGirl.define do
  factory :upload_manuscript_task, class: 'TahiStandardTasks::UploadManuscriptTask' do
    phase
    title "Upload Manuscript"
    role "author"
  end
end
