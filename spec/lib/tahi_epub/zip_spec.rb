require 'rails_helper'

describe TahiEpub::Zip do
  describe ".zip_file?" do
    it "returns true if the supplied file is a zip file" do
      expect(TahiEpub::Zip.zip_file?('spec/fixtures/blah.zip')).to eq(true)
    end

    it "returns true if the supplied file is a zip file" do
      expect(TahiEpub::Zip.zip_file?('garbage')).to eq(false)
    end
  end
end
