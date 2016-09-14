namespace :data do
  namespace :migrate do
    namespace :tasks do
      desc <<-DESC.strip_heredoc
        Creates ManuscriptAttachment versions from VersionedText records.

        This is an all or nothing task. It will either migrate everything
        over successfully or it will fail.

        This is also idempotent.

        This is for APERTA-7248.
      DESC
      task create_manuscript_attachment_versions: :environment do
        Paper.transaction do
          Paper.find_each do |paper|
            # For idempotency, bail if this is run twice for the same paper.
            next if paper.file

            # We expect the same number of historical versions as there are
            # versioned_text records for a paper.
            expected_versions_count = paper.versioned_texts.count
            attachment = paper.build_file
            attachment.notifications_enabled = false

            paper.versioned_texts.order(:id).each do |versioned_text|
              attachment.s3_dir = "uploads/versioned_text/#{versioned_text.id}"
              attachment['file'] = versioned_text.source
              attachment.created_at = versioned_text.created_at
              attachment.updated_at = versioned_text.updated_at
              attachment.old_id = versioned_text.id
              attachment.uploaded_by_id = versioned_text.submitting_user_id
              attachment.type = 'ManuscriptAttachment'
              attachment.owner_type = 'Paper'
              attachment.owner_id = versioned_text.paper_id
              attachment.paper_id = versioned_text.paper_id
              attachment.title = versioned_text.source
              attachment.status = versioned_text.source.nil? ? 'processing' : 'done'
              attachment.save
            end

            if attachment.versions.count != expected_versions_count
              fail "Expected #{expected_versions_count} historical versions on Paper id=#{paper.id} but got #{attachment.versions.count}). Rolling back."
            end
          end
        end
      end
    end
  end
end
