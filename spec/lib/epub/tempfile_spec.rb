require 'spec_helper'

describe Epub::Tempfile do
  describe ".create" do
    it "creates a binary tempfile with the given stream" do
      contents = "Hello World"
      file_contents = Epub::Tempfile.create(contents) do |file|
        File.open(file.path).read
      end

      expect(contents).to eq(file_contents)
    end

    it "returns the value from the block" do
      return_value = Epub::Tempfile.create("Hello World") do |file|
        1234
      end

      expect(return_value).to eq(1234)
    end

    it "deletes the created tempfile afterwards" do
      file = Epub::Tempfile.create("Testing") do |file|
        file
      end

      expect(file).to be_closed
      expect(file.path).to be_nil
    end

    context "when an error is raised" do
      it "ensures the file is closed and deleted" do
        file = Epub::Tempfile.create("Testing") do |file|
          begin
            raise StandardError
          rescue StandardError
            file
          end
        end

        expect(file).to be_closed
        expect(file.path).to be_nil
      end
    end
  end
end
