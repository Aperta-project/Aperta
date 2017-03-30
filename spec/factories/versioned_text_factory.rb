FactoryGirl.define do
  factory :versioned_text do
    major_version 1
    minor_version 0
    paper
    text "Now, this is the story all about how my life got flipped-turned upside down"
    manuscript_s3_path 'example/path'
    manuscript_filename 'example_filename.docx'
    file_type 'docx'
  end
end
