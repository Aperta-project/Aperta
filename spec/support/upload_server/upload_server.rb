require 'sinatra/base'
require "pry"

class UploadServer < Sinatra::Base
  def self.store
    @@store ||= {}
  end

  configure do
    set :server, :thin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Method'] = 'PUT, POST'
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
