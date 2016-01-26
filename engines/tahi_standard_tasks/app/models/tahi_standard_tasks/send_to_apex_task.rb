module TahiStandardTasks
  #
  # This task sends a zip file of the manuscript and its metadata to APEX for
  # typesetting. The process is manually triggered by an editor or admin
  # pressing a button on this task.
  #
  # This task is the *end* of the Aperta workflow; after handoff to APEX, the
  # paper is no longer active in Aperta.
  #
  # This task works hand-in-hand with the ApexDelivery model.
  #
  class SendToApexTask < Task
    has_many :apex_deliveries, foreign_key: 'task_id', dependent: :destroy

    register_task default_title: 'Send to Apex', default_role: 'editor'
  end
end
