class Page
  include Capybara::DSL
  include RSpec::Matchers

  class << self
    include Capybara::DSL

    attr_reader :_path_regex

    def path path_sym
      all_routes = Rails.application.routes.routes
      inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
      route = inspector.instance_variable_get(:@routes).detect { |p| p.name == path_sym.to_s }
      @_path = "#{path_sym}_path"
      @_path_regex = ActionDispatch::Routing::RouteWrapper.new(route).json_regexp
    end

    def visit args = []
      page.visit Rails.application.routes.url_helpers.send @_path, *args
      new
    end
  end

  def initialize
    expect(current_path).to match self.class._path_regex
  end

  def reload
    visit page.current_path
  end

  def notice
    find('p.notice').text
  end

  def navigate_to_dashboard
    within('#nav-bar') do
      click_on 'Dashboard'
      DashboardPage.new
    end
  end
end
