EmberCli.configure do |c|
  c.app(:client, {
    path: Rails.root.join('client'),
    # use locally installed bower bin
    bower_path: Rails.root.join('client', 'node_modules', '.bin', 'bower'),
    build_timeout: 40
  })
end
