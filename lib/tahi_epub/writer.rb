module TahiEpub
  class Writer
    attr_reader :stream

    def initialize(stream:)
      @stream = stream
    end

    def converted_filename
      'converted.json'
    end

    def insert(converted_data)
      TahiEpub::Tempfile.create converted_data do |converted_file|
        TahiEpub::Tempfile.create stream, delete: false do |epub|
          ::Zip::File.open(epub.path) { |zip_file|
            zip_file.add 'converted.json', converted_file.path
          }

          epub.path
        end
      end
    end
  end
end
