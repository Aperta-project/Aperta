class ReassignDecisionAttachments < DataMigration
  RAKE_TASK_UP =
    'data:migrate:reassign_attachments_to_completed_decisions'.freeze
end
