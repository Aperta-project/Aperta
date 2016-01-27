Kaminari.configure do |config|
  config.default_per_page = 15
  config.max_per_page = 500 # protects against unusually large per pages
end
