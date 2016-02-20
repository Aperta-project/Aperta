EmberCli.configure do |c|
  c.app(:tahi, {
    path: Rails.root.join('client'),
    # use locally installed bower bin
    bower_path: Rails.root.join('node_modules', '.bin', 'bower'),
    build_timeout: 40
  })
end
