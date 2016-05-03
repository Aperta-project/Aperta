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
      apex_delivery.delivery_in_progress!

      file = ApexPackager.create_zip(@paper)

      FtpUploaderService.new(
        filepath: file.path,
        filename: "#{@paper.manuscript_id}.zip"
      ).upload

      apex_delivery.delivery_succeeded!

    rescue StandardError => e
      apex_delivery.delivery_failed!(e.message)
      raise
    end
  end
end
