EmberCli.configure do |c|
  c.app(:client, {
    path: Rails.root.join('client'),
    # use locally installed bower bin
    bower_path: Rails.root.join('client', 'node_modules', '.bin', 'bower'),
    build_timeout: (ENV['RACK_TIMEOUT'] || 30).to_i,
    yarn: true
  })
end
