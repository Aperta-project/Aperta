require 'zip'

module Epub
  class Zip
    def self.extract_file_from_zip(stream:, filename:)
      directory = ::Zip::CentralDirectory.read_from_stream StringIO.new(stream)
      directory.detect { |e| e.name == filename }.get_input_stream.read
    end
  end
end
