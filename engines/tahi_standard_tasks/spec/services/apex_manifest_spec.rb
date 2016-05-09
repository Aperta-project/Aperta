require 'rails_helper'

describe ApexManifest do
  let(:archive_filename) { "pbio.1012345.zip" }
  let(:metadata_filename) { "metadata.json" }
  let(:apex_delivery_id) { 1 }
  let(:file_1) { "img_1.jpg" }
  let(:file_2) { "document.docx" }
  let(:manifest) do
    ApexManifest.new archive_filename: archive_filename,
                     metadata_filename: metadata_filename,
                     apex_delivery_id: apex_delivery_id
  end

  describe "#add_file" do
    it "adds a file to the manifest's @file_list" do
      expect { manifest.add_file file_1 }
        .to change { manifest.instance_variable_get :@file_list }
        .from([]).to([file_1])
    end
  end

  describe "#as_json" do
    let(:manifest_with_files) do
      manifest.tap do |m|
        m.add_file file_1
        m.add_file file_2
      end
    end

    it "returns the manifest as a hash" do
      manifest_hash = manifest_with_files.as_json
      expected_hash = {
        archive_filename: archive_filename,
        metadata_filename: metadata_filename,
        apex_delivery_id: apex_delivery_id,
        files: [file_1, file_2]
      }
      expect(manifest_hash).to match expected_hash
    end
  end

  describe "#file" do
    it "returns a json file" do
      file = manifest.file
      expect(file).to be_an_instance_of(Tempfile)
      contents = file.read
      expect(contents).to eq manifest.to_json
    end

    it "fails if there is no archive_filename" do
      manifest.archive_filename = nil
      expect { manifest.file }.to raise_error(ApexManifest::InvalidManifest)
    end

    it "fails if there is no metadata_filename" do
      manifest.metadata_filename = nil
      expect { manifest.file }.to raise_error(ApexManifest::InvalidManifest)
    end
  end
end
