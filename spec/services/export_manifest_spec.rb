# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

require 'rails_helper'

describe ExportManifest do
  let(:archive_filename) { "pbio.1012345.zip" }
  let(:metadata_filename) { "metadata.json" }
  let(:delivery_id) { 1 }
  let(:file_1) { "img_1.jpg" }
  let(:file_2) { "document.docx" }
  let(:manifest) do
    ExportManifest.new archive_filename: archive_filename,
                       metadata_filename: metadata_filename,
                       delivery_id: delivery_id,
                       destination: 'apex'
  end

  describe "#add_file" do
    it "adds a file to the manifest's @file_list" do
      expect { manifest.add_file file_1 }
        .to change { manifest.file_list }
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

    context 'apex' do
      it 'returns the manifest as a hash' do
        manifest_hash = manifest_with_files.as_json
        expected_hash = {
          archive_filename: archive_filename,
          metadata_filename: metadata_filename,
          files: [file_1, file_2],
          apex_delivery_id: delivery_id
        }
        expect(manifest_hash).to match expected_hash
      end
    end

    context 'em and preprint' do
      let(:manifest) do
        ExportManifest.new archive_filename: archive_filename,
                           metadata_filename: metadata_filename,
                           delivery_id: delivery_id,
                           destination: 'preprint'
      end

      it 'returns the manifest as a hash' do
        manifest_hash = manifest_with_files.as_json
        expected_hash = {
          archive_filename: archive_filename,
          metadata_filename: metadata_filename,
          files: [file_1, file_2],
          export_delivery_id: delivery_id
        }
        expect(manifest_hash).to match expected_hash
      end
    end
  end

  describe "#file" do
    it "returns a json file" do
      file = manifest.file
      expect(file).to be_an_instance_of(Tempfile)
      contents = file.read
      expect(contents).to eq manifest.to_json
    end
  end
end
