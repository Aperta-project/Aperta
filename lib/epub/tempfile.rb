module Epub
  module Tempfile
    def self.create(stream, filename: SecureRandom.hex(6), delete: true, &block)
      tempfile = ::Tempfile.new filename
      tempfile.binmode
      tempfile.write stream
      tempfile.rewind

      return block.call(tempfile)
    ensure
      tempfile.close
      tempfile.unlink if delete
    end
  end
end
