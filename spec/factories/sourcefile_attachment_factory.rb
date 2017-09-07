FactoryGirl.define do
  factory :sourcefile_attachment, parent: :attachment, class: 'SourcefileAttachment' do
    association :owner, factory: :paper
    paper

    trait :with_filename do
      after :stub do |sourcefile_attachment|
        sourcefile_attachment[:file] = 'source.docx'
      end
    end

    trait :with_pending_url do
      after :stub do |sourcefile_attachment|
        sourcefile_attachment.pending_url = 'http://tahi-test.s3.amazonaws.com/temp/source.docx'
      end
    end
  end
end
