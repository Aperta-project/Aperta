class ChangeReviseManuscriptAttachmentOwner < DataMigration
  RAKE_TASK_UP =
    'data:migrate:revise_manuscript_attachment:change_owner_to_decision'.freeze
  RAKE_TASK_DOWN =
    'data:migrate:revise_manuscript_attachment:change_owner_to_task'.freeze
end
