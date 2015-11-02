require 'spec_helper'
require 'fog'
require_relative '../../../lib/tahi_epub/storage'
describe TahiEpub::Storage do

  let(:file) { File.open(File.expand_path("../../../fixtures/equations.epub", __FILE__)) }
  let(:directory) { connection.directories.get(bucket) }
  let(:connection) { described_class.new('1234').connection }
  let(:bucket) { ENV['S3_BUCKET'] }

  let(:job_id) { '1234' }

  before do
    Fog.mock!
    directory = connection.directories.create(key: bucket)
    directory.files.create({
      key: "#{job_id}/manuscript.docx",
      body: "Blah Blah"
    })
  end

  describe "#put" do
    it "uploads the file" do
      result = described_class.new('1234').put('blahblah', file)
      expect(directory.files.get('1234/blahblah').body.size).to eq(file.size)
    end
  end

  describe "#get" do
    it "gets the Fog object for the specified filename from the job directory" do
      file = described_class.new('1234').get('manuscript.docx')
      expect(file).to be_kind_of(Fog::Storage::AWS::File)
      expect(file.body.size).to be > 0
    end
  end
end
