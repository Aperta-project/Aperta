require 'sinatra/base'

class UploadServer < Sinatra::Base
  configure do
    set :server, :thin
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Method'] = 'PUT, POST'
  end

  post '/' do
    xml_response
  end

  put '/' do
    xml_response
  end

  options '/' do
  end

  private

  def xml_response
    content_type 'text/xml'
    '<PostResponse><Location>http://localhost:31337/fake_s3/fake_file</Location></PostResponse>'
  end

  run! if app_file == $0
end
