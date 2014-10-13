module Epub
  module Tempfile
    def self.create(stream, &block)
      tempfile = ::Tempfile.new ["converted_manuscript", ".epub"]
      tempfile.binmode
      tempfile.write stream
      tempfile.rewind

      return block.call(tempfile)
    ensure
      tempfile.close
      tempfile.unlink
    end
  end
end
