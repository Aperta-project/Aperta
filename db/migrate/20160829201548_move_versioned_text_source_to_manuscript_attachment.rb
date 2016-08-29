class MoveVersionedTextSourceToManuscriptAttachment < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO attachments (s3_dir,                                file,   created_at, updated_at, old_id, uploaded_by_id,     type,                   owner_type, owner_id, paper_id, title,  status)
      SELECT                   CONCAT('uploads/versioned_text/', id), source, created_at, updated_at, id,     submitting_user_id, 'ManuscriptAttachment', 'Paper',    paper_id, paper_id, source, (CASE WHEN source IS NULL THEN 'processing' ELSE 'done' END) FROM versioned_texts
    SQL
  end

  def down
    execute <<-SQL
      DELETE FROM attachments WHERE type='ManuscriptAttachment'
    SQL
  end
end
