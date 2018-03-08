module TahiStandardTasks
  # Defines the json object sent in response to requests for ExportDelivery
  # objects.
  class ExportDeliverySerializer < AuthzSerializer
    attributes :id, :state, :created_at, :error_message, :destination

    has_one :task, embed: :id, polymorphic: true
    has_one :paper, embed: :id
    has_one :user, embed: :id
  end
end
