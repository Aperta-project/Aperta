FactoryGirl.define do
  factory :manuscript do
    source Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/about_turtles.docx')))
  end
end
