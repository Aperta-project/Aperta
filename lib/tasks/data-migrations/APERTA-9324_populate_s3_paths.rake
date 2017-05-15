namespace :data do
  namespace :migrate do
    desc <<-DESC
      APERTA-9324 backfill missing s3 data on versioned_texts
    DESC
    task populate_s3_paths: :environment do
      DataTransformation::PopulateS3Paths.new.call
    end
  end
end
