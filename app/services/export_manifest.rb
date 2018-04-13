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

# A class for creating a validated manifest file for apex/router export
class ExportManifest
  class InvalidManifest < StandardError; end

  attr_accessor :archive_filename, :metadata_filename, :delivery_id
  attr_reader :file_list

  def initialize(archive_filename:,
                 metadata_filename:,
                 destination:,
                 delivery_id: nil)
    @file_list = []
    @archive_filename = archive_filename
    @metadata_filename = metadata_filename
    @delivery_id = delivery_id
    @destination = destination
  end

  def add_file(filename)
    @file_list << filename
  end

  def as_json(_ = nil)
    {
      archive_filename: archive_filename,
      metadata_filename: metadata_filename,
      files: file_list
    }.tap do |m|
      m[delivery_id_key] = delivery_id if delivery_id.present?
    end
  end

  def file
    Tempfile.new('manifest').tap do |f|
      f.write to_json
      f.rewind
    end
  end

  private

  def delivery_id_key
    @destination == 'apex' ? :apex_delivery_id : :export_delivery_id
  end
end
