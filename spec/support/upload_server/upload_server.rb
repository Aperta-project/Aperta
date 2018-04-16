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

require 'sinatra/base'

# UploadServer is used to mimick Amazon S3 and handle file uploads when running
# integration/feature specs.
#
# The reason this exists is because uploading files in a browser (e.g. through
# Selenium) POST/PUTs them directly to Amazon S3 (per the S3_URL env
# var). Due to this VCR cannot be used to intercept those requests and stub
# their responses. This also prevents the uploads from successfully completing
# when running feature specs.
#
# Additional Notes:
#
# * uploading a file will store it in-memory, you can later GET that file back
# * be sure to call UploadServer.clear_all_uploads to eliminate bleed over from
#   one test to another.
#
class UploadServer < Sinatra::Base
  def self.clear_all_uploads
    store.clear
  end

  def self.store
    @@store ||= {}
  end

  configure do
    set :server, :thin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Method'] = 'PUT, POST'
    response.headers['Access-Control-Allow-Headers'] = 'x-csrf-token'
  end

  get "/:filename" do
    send_file self.class.store[params[:filename]].path
  end

  post '/' do
    filename, file = params[:file].values_at(:filename, :tempfile)
    store(filename, file)
    xml_response(filename)
  end

  put '/' do
    filename, file = params[:file].values_at(:filename, :tempfile)
    xml_response(filename)
  end

  options '/' do
  end

  private

  def store(key, value)
    self.class.store[key] = value
  end

  def server_url
    "http://#{Capybara.server_host}:#{Capybara.server_port}"
  end

  def xml_response(filename)
    content_type 'application/xml'
    "<PostResponse><Location>#{server_url}/fake_s3/#{filename}</Location></PostResponse>"
  end

  run! if app_file == $0
end
