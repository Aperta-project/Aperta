module EventStreamNotifier
  extend ActiveSupport::Concern
  included do

    after_update :notify_commit
    after_create :notify_commit
    after_destroy :notify_destroy

    def notify_commit
      ActiveSupport::Notifications.instrument('updated', id: id_for_stream)
    end

    def notify_destroy
      ActiveSupport::Notifications.instrument('deleted', id: id, journal_id: journal.id)
    end

    def id_for_stream
      id
    end
  end

end
