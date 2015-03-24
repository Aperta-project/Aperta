module TahiEpub
  class Reader
    attr_reader :stream

    def initialize(stream:)
      raise FileNotFoundError, "no stream was found" unless stream
      @stream = stream
    end

    def source_filename
      'source.docx'
    end

    def source(&block)
      source_stream = Zip.extract(stream: stream, filename: source_filename)
      TahiEpub::Tempfile.create source_stream do |file|
        if block_given?
          block.call(file)
        else
          file
        end
      end
    end

    def content
      Zip.extract(stream: stream, filename: 'content')
    end
  end
end
