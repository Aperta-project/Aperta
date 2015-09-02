module Subscriptions

  # Print subscription detail as a nicely formatted table
  #
  # usage:
  # ConsoleFormatter.new(["header 1", "header 2"], [["row 1 column 1", "row 2 column 2"]])
  #
  class ConsoleFormatter

    def initialize(headers, row_data)
      @headers = headers
      @row_data = row_data
      @widths = calculate_widths
      @out = StringIO.new
      format!
    end

    def to_s
      @out.string
    end

    private

    def format!
      @out.puts format_row(@headers)
      @row_data.each do |row|
        @out.puts format_row(row)
      end
    end

    def format_row(row)
      row.map.with_index { |data, col|
        data.ljust(@widths[col])
      }.join(' ')
    end

    def calculate_widths
      @headers.map.with_index do |header, i|
        column_max(header, i)
      end
    end

    def column_max(column_header, col)
      (@row_data.map { |row| row[col].length } + [column_header.length]).max
    end
  end

end
