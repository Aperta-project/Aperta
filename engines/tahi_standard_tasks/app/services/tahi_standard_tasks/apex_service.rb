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

    class ApexServiceError < StandardError; end

    attr_reader :apex_delivery

    def initialize(apex_delivery:)
      @apex_delivery = apex_delivery
      @paper = @apex_delivery.paper
      @task = @apex_delivery.task
    end

    def make_delivery!
      while_notifying_delivery do
        packager = ApexPackager.new @paper,
                                    archive_filename: package_filename,
                                    apex_delivery_id: apex_delivery.id
        upload_file(packager.zip_file, package_filename)
        upload_file(packager.manifest_file, manifest_filename)
      end
    end

    private

    def while_notifying_delivery
      apex_delivery.delivery_in_progress!
      yield
      apex_delivery.delivery_succeeded!
    rescue StandardError => e
      apex_delivery.delivery_failed!(e.message)
      raise
    end

    def package_filename
      fail_unless_manuscript_id
      "#{@paper.manuscript_id}.zip"
    end

    def manifest_filename
      fail_unless_manuscript_id
      "#{@paper.manuscript_id}.man.json"
    end

    def fail_unless_manuscript_id
      return if @paper.manuscript_id.present?
      fail ApexServiceError, "Paper is missing manuscript_id"
    end

    def upload_file(filepath, filename)
      FtpUploaderService.new(
        filepath: filepath,
        filename: filename
      ).upload
    end
  end
end
