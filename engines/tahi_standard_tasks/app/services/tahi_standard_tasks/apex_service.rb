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

    attr_reader :apex_delivery,
                :paper,
                :task,
                :ftp_url,
                :router_url,
                :destination,
                :packager,
                :staff_emails

    def initialize(apex_delivery:, ftp_url: TahiEnv.apex_ftp_url, router_url: TahiEnv.router_url)
      @apex_delivery = apex_delivery
      @paper = @apex_delivery.paper
      @task = @apex_delivery.task
      @ftp_url = ftp_url
      @router_url = router_url
      @destination = apex_delivery.destination
      @staff_emails = paper.journal.staff_admins.pluck(:email)
    end

    def make_delivery!
      while_notifying_delivery do
        @packager = ApexPackager.new paper,
                                    archive_filename: package_filename,
                                    apex_delivery_id: apex_delivery.id

        paper.ensure_preprint_doi! if needs_preprint_doi?

        if destination == 'apex'
          upload_to_ftp(packager.zip_file, package_filename)
          upload_to_ftp(packager.manifest_file, manifest_filename)
        else
          upload_to_router
        end
      end
    end

    private

    def needs_preprint_doi?
      destination == 'preprint' && !paper.preprint_opt_out?
    end

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
      "#{paper.manuscript_id}.zip"
    end

    def manifest_filename
      fail_unless_manuscript_id
      "#{paper.manuscript_id}.man.json"
    end

    def fail_unless_manuscript_id
      return if paper.manuscript_id.present?
      raise ApexServiceError, "Paper is missing manuscript_id"
    end

    def upload_to_ftp(file_io, filename)
      FtpUploaderService.new(
        file_io: file_io,
        final_filename: filename,
        email_on_failure: staff_emails,
        url: ftp_url
      ).upload
    end

    def upload_to_router
      RouterUploaderService.new(
        destination: destination,
        email_on_failure: staff_emails,
        file_io: packager.zip_file(include_pdf: true),
        final_filename: package_filename,
        filenames: packager.manifest.file_list,
        paper: paper,
        url: router_url
      ).upload
    end
  end
end
