module TahiStandardTasks
  #
  # This task sends a zip file of the manuscript and its metadata to APEX for
  # typesetting. The process is manually triggered by an editor or admin
  # pressing a button on this task.
  #
  # This task is the *end* of the Aperta workflow; after handoff to APEX, the
  # paper is no longer active in Aperta.
  #
  class SendToApexTask < Task
    register_task default_title: 'Send to Apex', default_role: 'editor'

    def send_to_apex
      puts 'OH NO I SENT TO APEX WHAT NOW?'
    end
  end
end
