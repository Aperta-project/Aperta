class BackfillMissingInvitationTokens < DataMigration
  RAKE_TASK_UP = 'data:migrate:invitations:add_invitation_tokens'
end
