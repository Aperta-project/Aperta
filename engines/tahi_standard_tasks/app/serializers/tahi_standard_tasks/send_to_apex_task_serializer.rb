module TahiStandardTasks
  class SendToApexTaskSerializer < ::TaskSerializer
    has_many :apex_deliveries, embed: :id, include: true
  end
end
