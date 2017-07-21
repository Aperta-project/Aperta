namespace :data do
  namespace :migrate do
    namespace :tasks do
      desc <<-DESC.strip_heredoc
        Creates ManuscriptAttachment versions from PaperVersion records.

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
            # paper_version records for a paper.
            expected_versions_count = paper.paper_versions.count
            attachment = paper.build_file
            attachment.notifications_enabled = false

            paper.paper_versions.order(:id).each do |paper_version|
              attachment.s3_dir = "uploads/paper_version/#{paper_version.id}"
              attachment['file'] = paper_version.source
              attachment.created_at = paper_version.created_at
              attachment.updated_at = paper_version.updated_at
              attachment.old_id = paper_version.id
              attachment.uploaded_by_id = paper_version.submitting_user_id
              attachment.type = 'ManuscriptAttachment'
              attachment.owner_type = 'Paper'
              attachment.owner_id = paper_version.paper_id
              attachment.paper_id = paper_version.paper_id
              attachment.title = paper_version.source
              attachment.status = paper_version.source.nil? ? 'processing' : 'done'
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
