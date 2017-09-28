# Responsible for serializing a ScheduledEvent model as an API response.
class ScheduledEventSerializer < ActiveModel::Serializer
  attributes :id, :name, :dispatch_at, :state, :finished

  def finished
    object.finished?
  end
end
