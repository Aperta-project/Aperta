# rubocop:disable all
namespace :data do
  namespace :migrate do
    task s3_attachments: ['data:migrate:s3_attachments:prepare', 'data:migrate:s3_attachments:perform']
    namespace :s3_attachments do
      desc <<-DESC.strip_heredoc
        Prepares migration of S3 attachments. Run perform next.
      DESC
      task prepare: :environment do
        Attachment.transaction do
          Attachment.all.each do |attachment|
            # if there are attachment(s) that failed during processing
            # then they won't have a file path, so skip them
            next unless attachment.file.path

            if attachment.s3_dir
              S3Migration.create!(
                source_url: attachment.file.path,
                attachment: attachment,
                version: false
              )
              if attachment.is_a?(QuestionAttachment)
                # QuestionAttachments did not have versions, but the converged
                # Attachment model assumes they do.
                next
              end

              attachment.file.versions.each_pair do |version, file|
                source_url = file.path
                base_name = File.basename(file.path)

                # SupportingInformationFile had its versions stored in
                # a different location than the main attachment due to
                # a bug (or at least very odd behavior) in CarrierWave
                # involving subclassing uploaders.
                if attachment.is_a?(SupportingInformationFile)
                  task = attachment.try(:task)
                  paper = attachment.try(:paper) || task.try(:paper)
                  if task && paper
                    source_dir = "uploads/paper/#{paper.id}/supporting_information_file/attachment/#{attachment.old_id}"
                    source_url = File.join(source_dir, base_name)
                  elsif !task
                    puts "Attachment has no task: #{attachment.inspect}"
                  elsif !paper
                    puts "Attachment has no paper: #{attachment.inspect}"
                  end

                elsif attachment.is_a?(AdhocAttachment)
                  task = attachment.try(:task)
                  paper = attachment.try(:paper) || task.try(:paper)
                  if task && paper
                    source_dir = "uploads/paper/#{paper.id}/attachment/file/#{attachment.old_id}"
                    source_url = File.join(source_dir, base_name)
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

      desc "Populates resource tokens with old s3 locations to not break links while we're migrating"

      task populate_old_links: :environment do

        Attachment.transaction do
          Attachment.all.each do |attachment|
            # if there are attachment(s) that failed during processing
            # then they won't have a file path, so skip them
            next unless attachment.file.path

            # Fields to update/create ResourceToken
            # { default_url: default_url, version_urls: version_urls }

            default_url = nil
            version_urls = {}

            if attachment.s3_dir
              default_url = attachment.file.path
              # QuestionAttachments did not have versions, but the converged
              # Attachment model assumes they do. Skip version_urls ur QuestionAttachment
              unless attachment.is_a?(QuestionAttachment)
                attachment.file.versions.each_pair do |version, file|
                  source_url = file.path
                  base_name = File.basename(file.path)

                  # SupportingInformationFile had its versions stored in
                  # a different location than the main attachment due to
                  # a bug (or at least very odd behavior) in CarrierWave
                  # involving subclassing uploaders.
                  if attachment.is_a?(SupportingInformationFile)
                    task = attachment.try(:task)
                    paper = attachment.try(:paper) || task.try(:paper)
                    if task && paper
                      source_dir = "uploads/paper/#{paper.id}/supporting_information_file/attachment/#{attachment.old_id}"
                      source_url = File.join(source_dir, base_name)
                      version_urls[version] = source_url
                    elsif !task
                      puts "Attachment has no task: #{attachment.inspect}"
                    elsif !paper
                      puts "Attachment has no paper: #{attachment.inspect}"
                    end

                  elsif attachment.is_a?(AdhocAttachment)
                    task = attachment.try(:task)
                    paper = attachment.try(:paper) || task.try(:paper)
                    if task && paper
                      source_dir = "uploads/paper/#{paper.id}/attachment/file/#{attachment.old_id}"
                      source_url = File.join(source_dir, base_name)
                      version_urls[version] = source_url
                    elsif !task
                      puts "Attachment has no task: #{attachment.inspect}"
                    elsif !paper
                      puts "Attachment has no paper: #{attachment.inspect}"
                    end
                    
                  else
                    # Version Urls for all others (Figures)
                    version_urls[version] = file.path
                  end
                end
              end

              if attachment.resource_token
                attachment.resource_token.update(default_url: default_url, version_urls: version_urls)
              else
                attachment.resource_tokens.create!({default_url: default_url, version_urls: version_urls})
              end
            else
              puts "Skipping attachment id=#{attachment.id} because it has no s3_dir."
            end
          end
        end
      end

      desc <<-DESC.strip_heredoc
        Performs migration of S3 attachments.
      DESC
      task perform: :environment do
        ::AttachmentUploader.include S3Migration::UploaderOverrides

        # Try three times to move all files in case we run into any problems
        # or rate-limiting issues with Amazon.
        range = (1..3)
        range.each do |i|
          puts
          puts "#"*100
          puts "Performing migration round #{i} of #{range.max}"
          puts "#"*100
          puts

          S3Migration.migrate!
          break if S3Migration.ready.count == 0

          sleep 3
        end
      end
    end
  end
end
