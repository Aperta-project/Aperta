module EventStreamNotifier
  extend ActiveSupport::Concern
  included do

    after_commit :notify_create_update, on: [:create, :update]
    after_commit :notify_destroy, on: [:destroy]

    def notify_create_update
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
