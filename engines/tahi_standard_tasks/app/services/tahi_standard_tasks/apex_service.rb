module TahiStandardTasks
  #
  # This service defines the sequence of getting the manuscript's metadata
  # together, collecting and naming the associated files, and FTPing the
  # resulting zip file to Apex for typesetting.
  #
  class ApexService
    def self.make_delivery(apex_delivery_id:)
      apex_delivery = ApexDelivery.find(apex_delivery_id)
      new(apex_delivery: apex_delivery).make_delivery!
    end

    attr_reader :apex_delivery

    def initialize(apex_delivery:)
      @apex_delivery = apex_delivery
      @paper = @apex_delivery.paper
      @task = @apex_delivery.task
    end

    def make_delivery!
      sleep 1
      apex_delivery.delivery_in_progress!

      # Start the upload...
      # TODO: <FILL ME IN>
      sleep 1

      # When things go well...
      apex_delivery.delivery_succeeded!

      # When things go bad...
      # apex_delivery.delivery_failed!
    end
  end
end
