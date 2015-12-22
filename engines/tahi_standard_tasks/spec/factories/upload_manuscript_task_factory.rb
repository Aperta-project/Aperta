FactoryGirl.define do
  factory :upload_manuscript_task, class: 'TahiStandardTasks::UploadManuscriptTask' do
    phase
    title "Upload Manuscript"
    old_role "author"
  end
end
