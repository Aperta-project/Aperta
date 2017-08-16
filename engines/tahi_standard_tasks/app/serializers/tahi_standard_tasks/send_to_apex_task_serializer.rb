module TahiStandardTasks
  class SendToApexTaskSerializer < ::TaskSerializer
    has_many :export_deliveries, embed: :id, include: true
  end
end
