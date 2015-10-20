Subscriptions.configure do
  add 'paper:data_extracted', Paper::DataExtracted::FinishUploadManuscriptTask, Paper::DataExtracted::NotifyUser
end
