# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
