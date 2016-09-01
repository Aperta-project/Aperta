# Single point of dispatch to Ihat for manuscripts
class ManuscriptAttachment::ProcessManuscript
  def self.call(_event_name, event_data)
    manuscript_attachment = event_data[:record]

    if manuscript_attachment.did_file_change?
      ProcessManuscriptWorker.perform_async(manuscript_attachment.id)
    else
      manuscript_attachment.paper.update!(processing: false)
    end
  end
end
