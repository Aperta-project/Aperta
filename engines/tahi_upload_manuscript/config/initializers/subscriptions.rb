UPLOAD_MANUSCRIPT_EVENTS = {
  'paper:data_extracted' => [Paper::DataExtracted::FinishUploadManuscriptTask],
}

UPLOAD_MANUSCRIPT_EVENTS.each do |event_name, subscriber_list|
  Notifier.subscribe(event_name, subscriber_list)
end
