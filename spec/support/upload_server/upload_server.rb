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
