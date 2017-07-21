module DataTransformation
  # Go back in time and set s3 information on our PaperVersion records
  class PopulateS3Paths < Base
    counter :inferred_paper_type,
            :not_done_attachment,
            :paper_versions_without_s3_fields,
            :no_manuscript_attachment,
            :migrated_paper_versions

    def transform
      paper_versions_without_s3_fields.find_each do |paper_version|
        increment_counter(:paper_versions_without_s3_fields)
        manuscript_attachment = find_manuscript_attachment(paper_version)
        if manuscript_attachment && manuscript_attachment.status == "done"
          update_paper_version(paper_version, manuscript_attachment)
          log("Populated s3 columns on PaperVersion: #{paper_version.id}")
          increment_counter(:migrated_paper_versions)
        elsif manuscript_attachment
          log("Not migrating not-done MA (id: #{manuscript_attachment.id})")
          increment_counter(:not_done_attachment)
        else
          log("Unable to find MA for paper_version (id: #{paper_version.id})")
          increment_counter(:no_manuscript_attachment)
        end
      end
    end

    def paper_versions_without_s3_fields
      PaperVersion
        .includes(paper: :file)
        .where("manuscript_s3_path IS NULL or manuscript_filename IS NULL")
    end

    def file_type_from_filename(filename)
      extname = File.extname(filename).split('.').last
      valid_extensions = ['doc', 'docx', 'pdf']
      assert(
        valid_extensions.include?(extname),
        "Invalid extension for #{filename}"
      )
      extname
    end

    def update_paper_version(paper_version, manuscript_attachment)
      file_name = manuscript_attachment[:file]
      assert(file_name, "encountered nil filename")
      if manuscript_attachment.file_type
        file_type = manuscript_attachment.file_type
      else
        file_type = file_type_from_filename(file_name)
        increment_counter(:inferred_paper_type)
      end
      assert(file_type, "Couldn't find file_type")

      assert(
        manuscript_attachment.s3_dir.present?,
        "setting blank s3_path or file for PaperVersion: #{paper_version.id}"
      )

      paper_version.update_columns( # don't trigger before_save
        manuscript_s3_path: manuscript_attachment.s3_dir,
        manuscript_filename: file_name,
        file_type: file_type
      )
    end

    def find_manuscript_attachment(paper_version)
      manuscript_attachment = paper_version.paper.file
      return unless manuscript_attachment
      if paper_version.latest_version?
        ma_version = manuscript_attachment
      else

        if manuscript_attachment.updated_at <= paper_version.updated_at
          ma_version = manuscript_attachment
        else
          ma_version = manuscript_attachment.versions
            .where('object IS NOT NULL')
            .map(&:reify)
            .sort_by(&:created_at)
            .select { |v| v.status == "done" }
            .select { |v| v.updated_at <= paper_version.updated_at }
            .last
          assert(ma_version.present?, "Could not find a MA version")
        end

        if ma_version == "done"
          vt_id_from_s3_dir = ma_version.s3_dir
            .scan(%r{(?<=paper_version/)\d+}).first
          if vt_id_from_s3_dir
            assert(
              vt_id_from_s3_dir.to_i == paper_version.id ||
                previous_paper_version_has_s3_dir(
                  paper_version,
                  ma_version.s3_dir
                ),
              "paper version id did not match s3 dir"
            )
          end
        end
      end
      ma_version
    end

    def previous_paper_version_has_s3_dir(paper_version, s3_dir)
      previous_paper_version = paper_version.paper.paper_versions
        .order(created_at: :asc)
        .where('created_at < ?', paper_version.created_at).last
      return false unless previous_paper_version
      s3_dir == previous_paper_version.manuscript_s3_path
    end
  end
end
