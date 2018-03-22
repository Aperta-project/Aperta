# Responsible for serializing a ScheduledEvent model as an API response.
class ScheduledEventSerializer < AuthzSerializer
  attributes :id, :name, :dispatch_at, :state, :finished

  def finished
    object.finished?
  end

  private

  # TODO: APERTA-12693 Stop overriding this
  def can_view?
    true
  end
end
