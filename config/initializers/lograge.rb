Tahi::Application.configure do
  # only used when lograge is enabled for the environment
  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params].reject do |k|
      ['controller', 'action'].include? k
    end

    # add additional items to single line log output
    {
      params: params,
      time: event.time,
      ip: event.payload[:ip],
    }
  end
end
