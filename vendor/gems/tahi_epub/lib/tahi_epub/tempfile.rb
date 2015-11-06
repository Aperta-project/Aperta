require 'tempfile'

module TahiEpub
  module Tempfile
    def self.create(stream, filename: SecureRandom.hex(6), delete: true, format: '.epub', &block)
      tempfile = ::Tempfile.new [filename, format]
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
