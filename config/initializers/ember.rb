EmberCLI.configure do |c|
  c.app(:tahi, {
    path: Rails.root.join('client'),
    build_timeout: 15,
    enable: -> path { !%r{/(?:api|assets)/}.match(path) }
  })
end
