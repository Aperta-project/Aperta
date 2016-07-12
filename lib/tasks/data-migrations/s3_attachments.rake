# rubocop:disable all
namespace :data do
  namespace :migrate do
    task s3_attachments: ['data:migrate:s3_attachments:prepare', 'data:migrate:s3_attachments:perform']
    namespace :s3_attachments do
      desc <<-DESC.strip_heredoc
        Prepares migration of S3 attachments. Run migrate next.
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
                source_url = file.path

                # SupportingInformationFile had its versions stored in
                # a different location than the main attachment due to
                # a bug (or at least very odd behavior) in CarrierWave
                # involving subclassing uploaders.
                if attachment.is_a?(SupportingInformationFile)
                  task = attachment.try(:task)
                  paper = attachment.try(:paper) || task.try(:paper)
                  if task && paper
                    source_url = "uploads/paper/#{paper.id}/supporting_information_file/attachment/#{attachment.old_id}"
                  elsif !task
                    puts "Attachment has no task: #{attachment.inspect}"
                  elsif !paper
                    puts "Attachment has no paper: #{attachment.inspect}"
                  end
                end

                S3Migration.create!(
                  source_url: source_url,
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

      desc <<-DESC.strip_heredoc
        Prepares migration of S3 attachments. Run migrate next.
      DESC
      task perform: :environment do
        ::AttachmentUploader.include S3Migration::UploaderOverrides

        S3Migration.transaction { S3Migration.migrate! }
      end
    end
  end
end
