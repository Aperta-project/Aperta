module TahiStandardTasks
  #
  # This service defines the sequence of getting the manuscript's metadata
  # together, collecting and naming the associated files, and, depending on
  # the destination, either FTPing the resulting zip file to Apex for typesetting,
  # or exporting the package to the article admin router service
  #
  # TODO: move this out of the engines dir
  #
  class ExportService
    def self.make_delivery(export_delivery_id:)
      export_delivery = ExportDelivery.find(export_delivery_id)
      new(export_delivery: export_delivery).make_delivery!
    end

    class ExportServiceError < StandardError; end

    attr_reader :export_delivery,
                :paper,
                :task,
                :ftp_url,
                :router_url,
                :destination,
                :packager,
                :staff_emails

    def initialize(export_delivery:, ftp_url: TahiEnv.apex_ftp_url, router_url: TahiEnv.router_url)
      @export_delivery = export_delivery
      @paper = @export_delivery.paper
      @task = @export_delivery.task
      @ftp_url = ftp_url
      @router_url = router_url
      @destination = export_delivery.destination
      @staff_emails = paper.journal.staff_admins.pluck(:email)
    end

    def make_delivery!
      while_notifying_delivery do
        @packager = ExportPackager.new paper,
                                    archive_filename: package_filename,
                                    delivery_id: export_delivery.id,
                                    destination: destination

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
      export_delivery.delivery_in_progress!
      yield
      # for apex exports, this marks the successful completion of the task
      # for router exports, there is an async status polling of the router service
      # that needs to complete first (see RouterUploadStatusWorker)
      export_delivery.delivery_succeeded! if destination == 'apex'
    rescue StandardError => e
      export_delivery.delivery_failed!(e.message)
      raise
    end

    def package_filename
      fail_unless_manuscript_id
      "#{paper.manuscript_id}.zip"
    end

    def router_package_filename
      "aperta-cover-letter.zip"
    end

    def manifest_filename
      fail_unless_manuscript_id
      "#{paper.manuscript_id}.man.json"
    end

    def fail_unless_manuscript_id
      return if paper.manuscript_id.present?
      raise ExportServiceError, "Paper is missing manuscript_id"
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
        file_io: packager.zip_file,
        final_filename: router_package_filename,
        filenames: packager.manifest.file_list,
        paper: paper,
        url: router_url,
        export_delivery_id: export_delivery.id
      ).upload
    end
  end
end
