stream_to_paper = EventStream::StreamToPaperChannel
unassign_reviewers = Paper::DecisionMade::UnassignReviewers

Subscriptions.configure do
  add 'paper:submitted', Paper::Submitted::ReopenRevisionTasks
  add 'paper:in_revision', unassign_reviewers
  add 'paper:accepted', unassign_reviewers
  add 'paper:rejected', unassign_reviewers
  add 'paper:withdrawn', unassign_reviewers

  add 'tahi_standard_tasks/apex_delivery:updated', stream_to_paper
  add 'tahi_standard_tasks/apex_delivery:delivery_succeeded',
      ApexDelivery::DeliverySucceeded::FlashSuccessMessage
end
