class Page
  include Capybara::DSL
  include RSpec::Matchers
  include Rails.application.routes.url_helpers
end
