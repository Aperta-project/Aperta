# Single point of dispatch to Ihat for manuscripts
class ManuscriptAttachment::ProcessManuscript
  def self.call(_event_name, event_data)
    manuscript_attachment = event_data[:record]
    if manuscript_attachment.did_file_change?
      if manuscript_attachment.file_type == 'pdf'
        # This is due to a subtle timing issue. We depend on slanger pushing an
        # "update" event to the client to let the client know that there is a
        # manuscript file that is ready for them. But we need them to subscribe
        # to the channel for this paper first, and sometimes it takes a little
        # longer for the subscription to happen. So just sleep here for a little
        # bit. We will fix this when we clean up the horrendous upload logic.
        # TODO: FIX in APERTA-11664
        sleep(3)
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
