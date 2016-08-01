stream_to_paper = EventStream::StreamToPaperChannel
invalidate_invitations = Paper::DecisionMade::InvalidateReviewerInvitations

Subscriptions.configure do
  add 'paper:resubmitted', Paper::Resubmitted::ReopenRevisionTasks
  add 'paper:in_revision', invalidate_invitations
  add 'paper:accepted', invalidate_invitations
  add 'paper:rejected', invalidate_invitations
  add 'paper:withdrawn', invalidate_invitations

  add 'tahi_standard_tasks/apex_delivery:updated', stream_to_paper
  add 'tahi_standard_tasks/apex_delivery:delivery_succeeded',
      ApexDelivery::DeliverySucceeded::FlashSuccessMessage
end
