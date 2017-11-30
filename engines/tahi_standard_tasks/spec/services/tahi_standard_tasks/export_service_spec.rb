require "rails_helper"

RSpec::Matchers.define :hash_has_keys do |expected_key_list|
  match { |hash| expected_key_list.all? { |s| hash.key? s } }
end

describe TahiStandardTasks::ExportService do
  let(:export_delivery) do
    FactoryGirl.build(:export_delivery).tap { |d| d.paper.doi = doi }
  end
  let(:doi) { "23423/journal.tur.0001" }
  let(:post_params) { [:metadata_filename, :aperta_id, :files, :destination, :journal_code, :archive_filename] }
  let(:router_connection) { double('Faraday') }
  let(:request) { double('Faraday::Request') }
  let(:response) { double('Faraday::Response') }
  let(:packager) do
    double('ExportPackager').tap do |d|
      allow(d).to receive(:zip_file).and_return(Tempfile.new('zip'))
      allow(d).to receive(:manifest_file).and_return(Tempfile.new('manifest'))
      allow(d).to receive_message_chain(:manifest, :file_list).and_return(['foo', 'bar'])
    end
  end
  let(:paper) { export_delivery.paper }
  let(:service) do
    TahiStandardTasks::ExportService.new export_delivery: export_delivery
  end

  describe "#make_delivery!" do
    before do
      allow(ExportPackager).to receive(:new).and_return packager
      # The paper must be 'accepted' to send to APEX or EM
      paper.update(publishing_state: 'accepted')
    end

    context "the destination is apex" do
      before do
        export_delivery.destination = "apex"
      end

      it "uploads two files" do
        expect(service).to receive(:upload_to_ftp)
                             .with(packager.zip_file, service.send(:package_filename))
        expect(service).to receive(:upload_to_ftp)
                             .with(packager.manifest_file, service.send(:manifest_filename))
        service.make_delivery!
      end

      context "the upload fails" do
        let(:turtle_message) { "bad_turtle" }
        before do
          allow(service).to receive(:upload_to_ftp).and_raise(turtle_message)
        end

        it "makes a failure notification" do
          expect(export_delivery).to receive(:delivery_failed!)
          expect { service.make_delivery! }.to raise_error(turtle_message)
        end
      end
    end

    context "the destination is preprint" do
      before do
        export_delivery.destination = "preprint"
        allow(service).to receive(:router_upload_connection).and_return router_connection
        allow(router_connection).to receive(:post).and_return(response)
        expect(router_connection).to receive(:post).with("/api/deliveries").and_return(response).and_yield(request)
      end

      it "submits a POST request to the router service" do
        expect(request).to receive(:body=).with(hash_has_keys(post_params))
        expect(response).to receive(:body).and_return({})
        expect(RouterUploadStatusWorker).to receive(:perform_in)
        service.make_delivery!
      end

      it "the POST request returns an error if a param value is missing" do
        allow(packager).to receive_message_chain(:manifest, :file_list).and_return([])
        expect { service.send(:make_delivery!) }.to raise_error(TahiStandardTasks::ExportService::ExportServiceError, /Missing required.*files/)
        expect(RouterUploadStatusWorker).to_not receive(:perform_in)
      end
    end
  end

  describe "#upload_to_ftp" do
    let(:filepath) { "turtles/about_turtles.docx" }
    let(:filename) { "about_turtles.docx" }

    it "uploads a file" do
      expect_any_instance_of(FtpUploaderService).to receive(:upload)
      service.send(:upload_to_ftp, filepath, filename)
    end
  end

  describe "#package_filename" do
    it "fails if there is no manuscript ID" do
      paper.doi = nil
      expect { service.send(:package_filename) }.to \
        raise_error(TahiStandardTasks::ExportService::ExportServiceError)
    end

    it "returns the filename of the package" do
      filename = service.send(:package_filename)
      expect(filename).to match(/tur.0001\.zip/)
    end
  end

  describe "#manifest_filename" do
    it "fails if there is no manuscript ID" do
      paper.doi = nil
      expect { service.send(:manifest_filename) }.to \
        raise_error(TahiStandardTasks::ExportService::ExportServiceError)
    end

    it "returns the filename of the package" do
      filename = service.send(:manifest_filename)
      expect(filename).to match(/tur.0001\.man.json/)
    end
  end

  describe "#needs_preprint_doi?" do
    let!(:task) {
      FactoryGirl.create(
        :custom_card_task,
        :with_card,
        paper: paper
      )
    }
    let!(:card_content) {
      FactoryGirl.create(
        :card_content,
        parent: task.card.content_root_for_version(:latest),
        ident: 'preprint-posting--consent',
        value_type: 'boolean',
        content_type: 'radio'
      )
    }

    context "the paper has not opted out of preprint" do
      before do
        task.find_or_build_answer_for(card_content: card_content, value: true).save
      end

      it "for a preprint export it needs a preprint doi" do
        export_delivery.destination = "preprint"
        expect(service.send(:needs_preprint_doi?)).to eq(true)
      end

      it "for a non-preprint export it does not need a doi" do
        export_delivery.destination = "apex"
        expect(service.send(:needs_preprint_doi?)).to eq(false)
      end
    end

    context "the paper has opted out of preprint" do
      before do
        task.find_or_build_answer_for(card_content: card_content, value: false).save
      end
      it "does not need a doi" do
        export_delivery.destination = "preprint"
        expect(service.send(:needs_preprint_doi?)).to eq(false)
      end
    end
  end
end
