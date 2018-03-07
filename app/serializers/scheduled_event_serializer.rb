# Responsible for serializing a ScheduledEvent model as an API response.
class ScheduledEventSerializer < AuthzSerializer
  attributes :id, :name, :dispatch_at, :state, :finished

  def finished
    object.finished?
  end
end
