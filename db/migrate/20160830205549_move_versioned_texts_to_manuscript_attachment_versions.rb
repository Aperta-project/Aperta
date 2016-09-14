# This migrates VersionedText#source attachments to ManuscriptAttachment
# in order to preserve history.
class MoveVersionedTextsToManuscriptAttachmentVersions < DataMigration
  RAKE_TASK_UP = 'data:migrate:tasks:create_manuscript_attachment_versions'

  def down
    execute <<-SQL
      DELETE FROM attachments WHERE type='ManuscriptAttachment';
      DELETE FROM versions WHERE item_type='Attachment'
    SQL
  end
end
