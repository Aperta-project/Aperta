require 'zip'

module TahiEpub
  module Zip
    def self.extract(stream:, filename:)
      directory = ::Zip::CentralDirectory.read_from_stream StringIO.new(stream)
      directory.detect{ |e| e.name =~ /#{filename}/ }.get_input_stream.read
    rescue NoMethodError
      raise FileNotFoundError, "could not find a file using stream: #{stream} and filename: #{filename}"
    end

    def self.zip_file?(stream)
      ::Zip::File.open(stream)
      true
    rescue ::Zip::Error
      false
    end
  end
end
