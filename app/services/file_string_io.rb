class FileStringIO < StringIO
  attr_reader :file_path

  def initialize(*args)
    super(*args[1..-1])
    @file_path = args[0]
  end

  def original_filename
    File.basename(file_path)
  end
end
