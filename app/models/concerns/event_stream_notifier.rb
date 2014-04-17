module EventStreamNotifier
  extend ActiveSupport::Concern
  included do

    after_commit :notify

    def notify
      ActiveSupport::Notifications.instrument('updated', id: id_for_stream)
    end

    def id_for_stream
      id
    end
  end

end
