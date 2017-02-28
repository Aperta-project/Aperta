class RemoveReviewersAsParticipants < DataMigration
  RAKE_TASK_UP =  'data:migrate:reviewers:remove_participant_roles'.freeze
  RAKE_TASK_DOWN = 'data:migrate:reviewers:add_back_participant_roles'.freeze
end
