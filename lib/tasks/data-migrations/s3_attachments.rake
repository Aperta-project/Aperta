# rubocop:disable all
namespace :data do
  namespace :migrate do
    task s3_attachments: ['data:migrate:s3_attachments:prepare', 'data:migrate:s3_attachments:perform']
    namespace :s3_attachments do
      desc <<-DESC.gsub(/^\s*\|/, '')
        |Prepares migration of S3 attachments. Run migrate next.
      DESC
      task prepare: :environment do
        Attachment.transaction do
          Attachment.all.each do |attachment|
            if attachment.s3_dir
              S3Migration.create!(
                source_url: attachment.file.path,
                attachment: attachment,
                version: false
              )

              attachment.file.versions.each_pair do |version, file|
                S3Migration.create!(
                  source_url: file.path,
                  attachment: attachment,
                  version: true
                )
              end
            else
              puts "Skipping attachment id=#{attachment.id} because it has no s3_dir."
            end
          end
        end
      end

      desc <<-DESC.gsub(/^\s*\|/, '')
        |Prepares migration of S3 attachments. Run migrate next.
      DESC
      task perform: :environment do
        ::AttachmentUploader.include S3Migration::UploaderOverrides

        S3Migration.transaction { S3Migration.migrate! }
      end
    end
  end
end
