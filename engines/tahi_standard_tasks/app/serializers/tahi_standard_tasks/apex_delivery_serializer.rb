module TahiStandardTasks
  # Defines the json object sent in response to requests for ApexDelivery
  # objects.
  class ApexDeliverySerializer < ::ActiveModel::Serializer
    attributes :id, :state, :created_at

    has_one :task, embed: :id, polymorphic: true
    has_one :paper, embed: :id
    has_one :user, embed: :id
  end
end
