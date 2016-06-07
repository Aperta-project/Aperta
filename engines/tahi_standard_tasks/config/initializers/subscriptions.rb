stream_to_paper = EventStream::StreamToPaperChannel

Subscriptions.configure do
  add 'paper:submitted', Paper::Submitted::ReopenRevisionTasks

  add 'tahi_standard_tasks/apex_delivery:updated', stream_to_paper
  add 'tahi_standard_tasks/apex_delivery:delivery_succeeded',
      ApexDelivery::DeliverySucceeded::FlashSuccessMessage
end
