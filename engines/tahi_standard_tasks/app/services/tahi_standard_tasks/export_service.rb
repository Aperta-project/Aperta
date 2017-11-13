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
    class StatusError < StandardError; end

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

    def export_status
      if export_delivery.service_id.present?
        response = router_status_connection.get("/api/deliveries/" + export_delivery.service_id)
        { job_status: response.body["job_status"],
          job_status_description: response.body["job_status_details"],
          preprint_posted: response.body["published_on_prod"] }
      else
        { job_status: "UNKNOWN",
          job_status_description: "No service job ID provided",
          preprint_posted: nil }
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
    rescue Faraday::ClientError => e
      response_body = JSON.parse e.response[:body]
      export_delivery.delivery_failed!(response_body['message'])
    rescue StandardError => e
      export_delivery.delivery_failed!(e.message)
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
      # execute initial article router service POST request
      response = router_upload_connection.post("/api/deliveries") do |request|
        request.body = router_payload
      end

      # save job id and poll downstream article ingestion job asynchronously
      export_delivery.service_id = response.body["job_id"]
      export_delivery.save!
      RouterUploadStatusWorker.perform_in(10.seconds, export_delivery.id)
    end

    def router_payload
      # build the zip archive along with the manifest.file_list
      archive_file = packager.zip_file
      {
        metadata_filename: 'metadata.json',
        aperta_id: aperta_id,
        files: packager.manifest.file_list.join(','),
        destination: export_delivery.destination,
        journal_code: paper.journal.doi_journal_abbrev,
        # The archive_filename is not a string but the file itself.
        archive_filename: Faraday::UploadIO.new(archive_file, '')
      }
    end

    def router_upload_connection
      Faraday.new(url: router_url) do |faraday|
        faraday.response :json
        faraday.request :multipart
        faraday.request :url_encoded
        faraday.use :gzip
        faraday.use Faraday::Response::RaiseError
        faraday.adapter :net_http
      end
    end

    def router_status_connection
      Faraday.new(url: TahiEnv.router_url) do |faraday|
        faraday.response :json
        faraday.request :url_encoded
        faraday.use Faraday::Response::RaiseError
        faraday.adapter :net_http
      end
    end

    def aperta_id
      "aperta.#{paper.id.to_s.rjust(7, '0')}"
    end
  end
end
