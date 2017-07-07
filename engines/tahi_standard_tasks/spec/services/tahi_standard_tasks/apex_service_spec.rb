require "rails_helper"

describe TahiStandardTasks::ApexService do
  let(:apex_delivery) do
    FactoryGirl.build(:apex_delivery).tap { |d| d.paper.doi = doi }
  end
  let(:doi) { "23423/journal.tur.0001" }
  let(:packager) do
    double('ApexPackager').tap do |d|
      allow(d).to receive(:zip_file).and_return(Tempfile.new('zip'))
      allow(d).to receive(:manifest_file).and_return(Tempfile.new('manifest'))
      allow(d).to receive_message_chain(:manifest, :file_list).and_return(['foo', 'bar'])
    end
  end
  let(:paper) { apex_delivery.paper }
  let(:service) do
    TahiStandardTasks::ApexService.new apex_delivery: apex_delivery
  end

  describe "#make_delivery!" do
    before do
      allow(ApexPackager).to receive(:new).and_return packager
    end

    context "the destination is apex" do
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
          expect(apex_delivery).to receive(:delivery_failed!)
          expect { service.make_delivery! }.to raise_error(turtle_message)
        end
      end
    end

    context "the destination is em or preprint" do
      it "uploads to the router" do
        apex_delivery.destination = "em"
        expect_any_instance_of(RouterUploaderService).to receive(:upload).and_return(nil)
        service.make_delivery!
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
        raise_error(TahiStandardTasks::ApexService::ApexServiceError)
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
        raise_error(TahiStandardTasks::ApexService::ApexServiceError)
    end

    it "returns the filename of the package" do
      filename = service.send(:manifest_filename)
      expect(filename).to match(/tur.0001\.man.json/)
    end
  end
end
