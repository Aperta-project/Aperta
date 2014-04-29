require 'sinatra/base'

class StreamServer < Sinatra::Base
  configure do
    set :server, :thin
    set connections: []
  end

  before do
    response.headers['Access-Control-Allow-Origin'] = '*'
  end

  id = 1

  # Do we want to enforce token checking?
  get '/stream', provides: 'text/event-stream' do
    stream :keep_open do |out|
      settings.connections << out
      out.callback { settings.connections.delete(out) }
    end
  end

  # Do we want to enforce token checking?
  post '/update_stream' do
    msg = create_msg params[:card], params[:stream], id
    settings.connections.each do |out|
      out << msg
    end
    id += 1
    204
  end

  private

  def create_msg data, stream, id
    str = ""
    str << "id: #{id}\n"
    str << "event: #{stream}\n"
    str << "data: #{data}\n\n"
    str
  end

  run! if app_file == $0
end
