FactoryGirl.define do
  factory :upload_manuscript_task, class: 'TahiUploadManuscript::UploadManuscriptTask' do
    phase
    title "Upload Manuscript"
    role "author"
  end
end
