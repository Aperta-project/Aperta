require 'csv'

class CsvStreamerRaw
  def initialize(io, headers)
    @io = io
    @options = { force_quotes: true }
    @io.write(CSV.generate_line(headers, @options))
  end

  def write_line_raw(*args)
    @io.write(CSV.generate_line(args, @options))
  end

  def close
    @io.close
  end
end
