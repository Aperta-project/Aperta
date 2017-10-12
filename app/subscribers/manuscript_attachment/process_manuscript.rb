# Single point of dispatch to Ihat for manuscripts
class ManuscriptAttachment::ProcessManuscript
  def self.call(_event_name, event_data)
    manuscript_attachment = event_data[:record]
    if manuscript_attachment.did_file_change?
      if manuscript_attachment.file_type == 'pdf'
        # no ihat processing required for PDFs, but in lieu of this,
        # paper.body requires updating in order to trigger versioned_text
        # creation with proper file_type (necessary for proper rendering)
        manuscript_attachment.paper.update!(body: '', processing: false)
      else
        ProcessManuscriptWorker.perform_async(manuscript_attachment.id)
      end
    else
      manuscript_attachment.paper.update!(processing: false)
    end
  end
end
