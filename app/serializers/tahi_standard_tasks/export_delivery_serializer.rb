module TahiStandardTasks
  # Defines the json object sent in response to requests for ExportDelivery
  # objects.
  class ExportDeliverySerializer < AuthzSerializer
    attributes :id, :state, :created_at, :error_message, :destination

    has_one :task, embed: :id, polymorphic: true
    has_one :paper, embed: :id
    has_one :user, embed: :id

    private

    # TODO: APERTA-12693 Stop overriding this
    def can_view?
      true
    end
  end
end
