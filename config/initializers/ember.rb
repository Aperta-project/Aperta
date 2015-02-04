EmberCLI.configure do |c|
  c.app :tahi, path: Rails.root.join('client'), build_timeout: 10
end
