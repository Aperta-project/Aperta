module DataTransformation
  # Go back in time and set s3 information on our VersionedText records
  class PopulateS3Paths < Base
    counter :inferred_paper_type,
            :not_done_attachment,
            :versioned_texts_without_s3_fields,
            :no_manuscript_attachment,
            :migrated_versioned_texts

    def transform
      versioned_texts_without_s3_fields.find_each do |versioned_text|
        increment_counter(:versioned_texts_without_s3_fields)
        manuscript_attachment = find_manuscript_attachment(versioned_text)
        if manuscript_attachment && manuscript_attachment.status == "done"
          update_versioned_text(versioned_text, manuscript_attachment)
          log("Populated s3 columns on VersionedText: #{versioned_text.id}")
          increment_counter(:migrated_versioned_texts)
        elsif manuscript_attachment
          increment_counter(:not_done_attachment)
        else
          increment_counter(:no_manuscript_attachment)
        end
      end
    end

    def versioned_texts_without_s3_fields
      VersionedText
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

    def update_versioned_text(versioned_text, manuscript_attachment)
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
        "setting blank s3_path or file for VersionedText: #{versioned_text.id}"
      )

      versioned_text.update_columns( # don't trigger before_save
        manuscript_s3_path: manuscript_attachment.s3_dir,
        manuscript_filename: file_name,
        file_type: file_type
      )
    end

    def find_manuscript_attachment(versioned_text)
      manuscript_attachment = versioned_text.paper.file
      return unless manuscript_attachment
      if versioned_text.latest_version?
        ma_version = manuscript_attachment
      else
        ma_version = manuscript_attachment
          .versions
          .where('object IS NOT NULL')
          .where('created_at > ?', versioned_text.updated_at + 5.seconds)
          .order(created_at: :asc).first.try(:reify)

        ma_version ||= manuscript_attachment

        assert(
          ma_version.updated_at <= versioned_text.updated_at,
          "could not find correct manuscript attachment version"
        )
      end
      ma_version
    end
  end
end
